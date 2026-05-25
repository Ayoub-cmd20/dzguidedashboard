import os
import json
import appwrite
from appwrite.client import Client
from appwrite.services.tables_db import TablesDB as Tables
from appwrite.query import Query
from appwrite.id import ID
from datetime import datetime
from dateutil.relativedelta import relativedelta

# ─────────────────────────────────────────────
# Config — all from environment variables
# ─────────────────────────────────────────────
ENDPOINT   = os.environ.get('APPWRITE_ENDPOINT',    'https://fra.cloud.appwrite.io/v1')
PROJECT_ID = os.environ.get('APPWRITE_PROJECT_ID',  '')
DATABASE_ID = os.environ.get('APPWRITE_DATABASE_ID', 'dz_guide_db')
API_KEY    = os.environ.get('APPWRITE_API_KEY', '')

MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

LUXURY_MIN_RATING     = 4.0
LUXURY_MIN_GUESTS     = 4
LUXURY_CATEGORIES     = {'luxury', 'resort', 'premium'}
LUXURY_BOOKING_WEIGHT = 0.5

# ─────────────────────────────────────────────
# Helper
# ─────────────────────────────────────────────
def get_field(doc, field, default=None):
    if field == '$id':
        return getattr(doc, 'id', default)
    if field == '$createdAt':
        return getattr(doc, 'created_at', default)
    return getattr(doc, field, default)

# ─────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────
def main(context):
    if not API_KEY:
        return context.res.json({
            'success': False,
            'error': 'APPWRITE_API_KEY environment variable not set'
        }, 401)

    client = Client()
    client.set_endpoint(ENDPOINT)
    client.set_project(PROJECT_ID)
    client.set_key(API_KEY)

    tables = Tables(client)          # new service

    try:
        # ── Determine previous month ──
        today = datetime.utcnow()
        first_of_current = datetime(today.year, today.month, 1)
        prev_month_end = first_of_current - relativedelta(days=1)
        prev_month_start = datetime(prev_month_end.year, prev_month_end.month, 1)

        year = prev_month_start.year
        month_num = prev_month_start.month
        month_name = MONTHS[month_num - 1]

        context.log(f"Calculating analytics for {month_name} {year} …")

        # ── Fetch all data (still full collections – but you can filter by date later) ──
        raw = fetch_all_data(tables, context)

        # ── Compute metrics for exactly that month ──
        luxury_places = build_luxury_lookup(raw['places'])
        metrics = calculate_monthly_metrics(
            raw['inquiries'], raw['users'],
            raw['reviews'], raw['events'],
            luxury_places,
            prev_month_start, prev_month_end + relativedelta(days=1)   # end is exclusive
        )

        analytics_record = {
            'month': month_name,
            'year': year,
            'luxuryBookings': metrics['luxury_bookings'],
            'eliteActivity': metrics['elite_activity'],
            'totalUsers': metrics['total_users'],
            'newInquiries': metrics['new_inquiries'],
        }

        upsert_analytics(tables, analytics_record)

        context.log(f"Done – {month_name} {year} updated.")
        return context.res.json({'success': True, 'data': analytics_record})

    except Exception as e:
        context.log(f"Fatal error: {e}")
        return context.res.json({'success': False, 'error': str(e)}, 500)


# ─────────────────────────────────────────────
# Fetch helpers (paginated)
# ─────────────────────────────────────────────
def fetch_collection(tables, table_id, context, page_size=1000):
    rows = []
    cursor = None

    while True:
        queries = [Query.limit(page_size)]
        if cursor:
            queries.append(Query.cursor_after(cursor))

        result = tables.list_rows(          # ← not list_rows
            database_id=DATABASE_ID,
            table_id=table_id,
            queries=queries,
        )

        batch = result.rows
        rows.extend(batch)

        if len(batch) < page_size:
            break

        cursor = batch[-1].id

    context.log(f"  Fetched {len(rows)} docs from '{table_id}'")
    return rows


def fetch_all_data(tables, context):
    context.log("Fetching collections …")
    return {
        'inquiries': fetch_collection(tables, 'inquiries', context),
        'users':     fetch_collection(tables, 'users',     context),
        'reviews':   fetch_collection(tables, 'reviews',   context),
        'events':    fetch_collection(tables, 'events',    context),
        'places':    fetch_collection(tables, 'places',    context),
    }


# ─────────────────────────────────────────────
# Analytics calculation (unchanged)
# ─────────────────────────────────────────────
def build_luxury_lookup(places):
    lookup = {}
    for place in places:
        rating = get_field(place, 'rating', 0.0) or 0.0
        cat_str = get_field(place, 'categories', '') or ''
        categories = set(cat_str.lower().split(','))
        categories = {c.strip() for c in categories}

        is_luxury = (
            rating >= LUXURY_MIN_RATING and
            bool(categories & LUXURY_CATEGORIES)
        )
        lookup[place.id] = is_luxury
    return lookup


def parse_iso(value):
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace('Z', '+00:00'))
    except (ValueError, AttributeError):
        return None


def calculate_yearly_analytics(raw, year):
    luxury_places = build_luxury_lookup(raw['places'])
    results = []

    for month_index in range(12):
        month_num = month_index + 1
        month_name = MONTHS[month_index]
        month_start = datetime(year, month_num, 1)
        month_end = datetime(year + 1, 1, 1) if month_num == 12 else datetime(year, month_num + 1, 1)

        metrics = calculate_monthly_metrics(
            raw['inquiries'], raw['users'],
            raw['reviews'],  raw['events'],
            luxury_places,
            month_start, month_end,
        )

        results.append({
            'month':          month_name,
            'year':           year,
            'luxuryBookings': metrics['luxury_bookings'],
            'eliteActivity':  metrics['elite_activity'],
            'totalUsers':     metrics['total_users'],
            'newInquiries':   metrics['new_inquiries'],
        })

    return results


def calculate_monthly_metrics(inquiries, users, reviews, events,
                               luxury_places, month_start, month_end):
    luxury_bookings = 0
    new_inquiries   = 0
    elite_reviews   = 0
    elite_events    = 0
    total_users     = 0

    for inq in inquiries:
        dt = parse_iso(get_field(inq, 'eventDate'))
        if dt is None:
            continue
        if month_start <= dt < month_end:
            new_inquiries += 1
            place_id    = get_field(inq, 'placeId', '')
            guest_count = get_field(inq, 'guestCount', 0) or 0
            if luxury_places.get(place_id, False) or guest_count >= LUXURY_MIN_GUESTS:
                luxury_bookings += 1

    for rev in reviews:
        dt = parse_iso(get_field(rev, 'createdAt'))
        if dt and month_start <= dt < month_end:
            elite_reviews += 1

    for evt in events:
        dt = parse_iso(get_field(evt, 'date'))
        if dt and month_start <= dt < month_end:
            elite_events += 1

    for user in users:
        dt = parse_iso(get_field(user, '$createdAt'))
        if dt is None:
            continue
        if dt < month_end:
            total_users += 1

    elite_activity = elite_reviews + elite_events + int(luxury_bookings * LUXURY_BOOKING_WEIGHT)

    return {
        'luxury_bookings': luxury_bookings,
        'elite_activity':  elite_activity,
        'total_users':     total_users,
        'new_inquiries':   new_inquiries,
    }


# ─────────────────────────────────────────────
# Upsert (uses Tables)
# ─────────────────────────────────────────────
def upsert_analytics(tables, data):
    month = data['month']
    year  = data['year']
    payload = {
        'luxuryBookings': data['luxuryBookings'],
        'eliteActivity':  data['eliteActivity'],
        'totalUsers':     data['totalUsers'],
        'newInquiries':   data['newInquiries'],
    }

    existing = tables.list_rows(          # replaced list_rows
        database_id=DATABASE_ID,
        table_id='analytics',
        queries=[Query.equal('month', month), Query.equal('year', year)],
    )

    if existing.total > 0:
        doc_id = existing.rows[0].id
        tables.update_row(               # replaced update_row
            database_id=DATABASE_ID,
            table_id='analytics',
            row_id=doc_id,
            data=payload,
        )
    else:
        tables.create_row(               # replaced create_row
            database_id=DATABASE_ID,
            table_id='analytics',
            data={'month': month, 'year': year, **payload},
            row_id=ID.unique(),
        )