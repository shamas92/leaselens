#!/bin/sh
# Seed the demo sample assets (leases, photos, walkthrough video) into
# storage/samples on first start, then serve the API. The seed script
# makes no AI API calls and never reads .env, so startup works fully
# offline; live endpoints pick up keys from the environment at runtime.
set -e

python seed_demo_cache.py
exec uvicorn main:app --host 0.0.0.0 --port 8000
