# 🧪 Running Tests & Viewing Pipeline

## 🔗 Quick Links

### GitHub Actions Pipeline
**URL**: https://github.com/mluk132/diaperstops.com/actions

Click the link above to see:
- ✅ Pipeline execution status
- ✅ Test results
- ✅ Coverage reports
- ✅ Scraped data artifacts
- ✅ Build logs

### Live Application
**URL**: https://diaperstopscom.vercel.app/

---

## 🚀 How to View the Pipeline

### Step 1: Open GitHub Actions
1. Go to: https://github.com/mluk132/diaperstops.com/actions
2. You'll see the "Scraper CI/CD Pipeline" workflow

### Step 2: View Latest Run
1. Click on the most recent workflow run (top of the list)
2. You'll see 4 jobs:
   - ✅ **test** - Unit tests
   - ✅ **scrape** - Data scraping
   - ✅ **integration-test** - Integration tests
   - ✅ **deploy-status** - Overall status

### Step 3: View Job Details
Click on any job to see:
- Detailed logs
- Test output
- Coverage reports
- Error messages (if any)

### Step 4: Download Artifacts
1. Scroll to bottom of workflow run page
2. Click "Artifacts" section
3. Download:
   - `coverage-report` - HTML coverage report
   - `scraped-data` - JSON files with location data

---

## 🧪 Running Tests Locally

### Unit Tests
```bash
cd projects/diaperstops.com/backend/scripts/scraper

# Run with unittest
python3 test_scraper.py

# Or with pytest (if installed)
pytest test_scraper.py -v
```

### Integration Tests
```bash
cd projects/diaperstops.com/backend/scripts/scraper

python3 test_integration.py
```

### Run Scraper Manually
```bash
cd projects/diaperstops.com/backend/scripts/scraper

export GOOGLE_MAPS_API_KEY="AIzaSyBnNkoRxSAyBYgS3BRnVK0jAyE18EDRvEE"
python3 google_places_scraper.py
```

---

## 📊 Expected Test Output

### Unit Tests (9 tests)
```
test_initialization (test_scraper.TestGooglePlacesScraper) ... ok
test_search_places_success (test_scraper.TestGooglePlacesScraper) ... ok
test_search_places_api_error (test_scraper.TestGooglePlacesScraper) ... ok
test_get_place_details (test_scraper.TestGooglePlacesScraper) ... ok
test_search_nearby_removes_duplicates (test_scraper.TestGooglePlacesScraper) ... ok
test_enrich_place_data (test_scraper.TestGooglePlacesScraper) ... ok
test_scrape_city (test_scraper.TestGooglePlacesScraper) ... ok
test_data_directory_creation (test_scraper.TestDataAggregation) ... ok
test_json_serialization (test_scraper.TestDataAggregation) ... ok

----------------------------------------------------------------------
Ran 9 tests in 0.123s

OK
```

### Integration Tests (6 tests)
```
test_backend_health (test_integration.TestScraperIntegration) ... ok
test_scraper_can_fetch_data (test_integration.TestScraperIntegration) ... ok
test_data_format_matches_backend (test_integration.TestScraperIntegration) ... ok
test_scraped_data_can_be_posted (test_integration.TestScraperIntegration) ... ok
test_data_directory_exists (test_integration.TestDataAggregationIntegration) ... ok
test_can_write_scraped_data (test_integration.TestDataAggregationIntegration) ... ok

----------------------------------------------------------------------
Ran 6 tests in 1.456s

OK
```

---

## 🎯 Verifying Everything Works

### 1. Check Frontend
Visit: https://diaperstopscom.vercel.app/

You should see:
- ✅ Google Map loading
- ✅ Search bar at top
- ✅ Featured spots carousel
- ✅ Category chips
- ✅ Location autocomplete working

### 2. Check Backend
Visit: https://diaperstops-backend.fly.dev/health

You should see:
```json
{
  "status": "UP",
  "database": "Connected",
  "service": "babyland-backend"
}
```

### 3. Check Pipeline
Visit: https://github.com/mluk132/diaperstops.com/actions

You should see:
- ✅ Green checkmarks for all jobs
- ✅ "Scraper CI/CD Pipeline" workflow
- ✅ Recent runs listed
- ✅ Artifacts available for download

### 4. Test Authentication
1. Go to https://diaperstopscom.vercel.app/signup
2. Enter email and password
3. Click "Sign Up"
4. Should redirect to home page
5. Should see user avatar in top right

### 5. Test Location Search
1. Click on "Post Your Location" section
2. Start typing an address
3. Should see autocomplete suggestions
4. Select an address
5. Should auto-navigate to post form after 2 seconds

---

## 📦 Viewing Scraped Data

### Option 1: Download from GitHub
1. Go to: https://github.com/mluk132/diaperstops.com/actions
2. Click latest workflow run
3. Scroll to "Artifacts"
4. Download "scraped-data"
5. Extract ZIP file
6. Open JSON files in text editor

### Option 2: View in Repository
```bash
cd projects/diaperstops.com/backend/scripts/scraper/data_aggregation
ls -la
# You'll see:
# - Halifax_NS.json
# - Toronto_ON.json
# - Vancouver_BC.json
# - all_cities.json

cat Halifax_NS.json | head -50
```

---

## 🔄 Triggering Pipeline Manually

### Method 1: Push to GitHub
```bash
cd projects/diaperstops.com
git add .
git commit -m "Trigger pipeline"
git push origin main
```

### Method 2: GitHub UI
1. Go to: https://github.com/mluk132/diaperstops.com/actions
2. Click "Scraper CI/CD Pipeline"
3. Click "Run workflow" button
4. Select branch (main)
5. Click "Run workflow"

---

## 📈 Monitoring Pipeline Status

### Real-time Monitoring
1. Open: https://github.com/mluk132/diaperstops.com/actions
2. Click on running workflow
3. Watch jobs execute in real-time
4. See logs streaming live

### Email Notifications
GitHub will email you when:
- ✅ Pipeline succeeds
- ❌ Pipeline fails
- ⚠️ Pipeline has warnings

---

## 🐛 Troubleshooting

### Pipeline Failing?
1. Check job logs in GitHub Actions
2. Look for error messages
3. Verify API key is set in GitHub Secrets
4. Check test output for failures

### Tests Failing Locally?
1. Ensure dependencies installed: `pip install -r requirements.txt`
2. Check Python version: `python3 --version` (should be 3.11+)
3. Verify API key is set: `echo $GOOGLE_MAPS_API_KEY`

### Scraper Not Finding Data?
1. Check API key is valid
2. Verify internet connection
3. Check API quota limits
4. Review scraper logs

---

## ✅ Success Checklist

- [ ] Pipeline URL accessible: https://github.com/mluk132/diaperstops.com/actions
- [ ] Latest workflow run shows green checkmarks
- [ ] All 4 jobs completed successfully
- [ ] Artifacts available for download
- [ ] Frontend loading: https://diaperstopscom.vercel.app/
- [ ] Backend responding: https://diaperstops-backend.fly.dev/health
- [ ] Google Maps showing on frontend
- [ ] Location search working
- [ ] Authentication working
- [ ] Tests passing (15/15)

---

## 🎉 You're All Set!

Everything is working:
- ✅ Frontend deployed
- ✅ Backend deployed
- ✅ Scraper running
- ✅ Tests passing
- ✅ Pipeline operational
- ✅ Data aggregating

**Pipeline**: https://github.com/mluk132/diaperstops.com/actions
**App**: https://diaperstopscom.vercel.app/

Enjoy! 🚀
