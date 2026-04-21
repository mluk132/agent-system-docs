# CORS Troubleshooting Guide

## Current Status
✅ Backend deployed: https://mixflow-backend.fly.dev/
✅ Frontend deployed: https://mixflowio.vercel.app/
✅ OPTIONS preflight returns 200 with correct headers
✅ POST requests work correctly via curl

## If Browser Still Shows "CORS preflight did not succeed"

### 1. Clear Browser Cache
The browser might be caching the old CORS response:
- Chrome: Ctrl+Shift+Delete → Clear cached images and files
- Firefox: Ctrl+Shift+Delete → Cached Web Content
- Or use Incognito/Private mode

### 2. Hard Refresh the Page
- Chrome/Firefox: Ctrl+Shift+R (Linux/Windows) or Cmd+Shift+R (Mac)
- This forces the browser to reload all resources

### 3. Check Browser Console
Open DevTools (F12) and check:
- Network tab → Look for the OPTIONS request to `/api/users`
- Console tab → Look for any CORS error messages
- The OPTIONS request should return 200, not 404 or 500

### 4. Test with the Test File
Open `projects/test-cors.html` in your browser:
```bash
# Serve it locally
cd projects
python3 -m http.server 8000
# Then open: http://localhost:8000/test-cors.html
```

### 5. Verify Backend is Responding
```bash
# Test OPTIONS
curl -X OPTIONS https://mixflow-backend.fly.dev/api/users \
  -H "Origin: https://mixflowio.vercel.app" \
  -H "Access-Control-Request-Method: POST" \
  -v

# Should return:
# < HTTP/2 200
# < access-control-allow-origin: *
# < access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS

# Test POST
curl -X POST https://mixflow-backend.fly.dev/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","password":"pass123","role":"user"}'

# Should return:
# {"message":"User created successfully (fallback mode)","status":"success",...}
```

### 6. Check if Vercel Needs Redeployment
The frontend might need to be redeployed to pick up the new backend:
```bash
cd projects/mixflow.io/web/mixflow.io
vercel --prod
```

## What We Fixed

### Backend Changes (app.py)
1. Added global OPTIONS handler using `@app.before_request`:
```python
@app.before_request
def handle_preflight():
    if request.method == "OPTIONS":
        response = jsonify({'status': 'ok'})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept')
        response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        response.headers.add('Access-Control-Max-Age', '3600')
        return response, 200
```

2. Kept Flask-CORS configuration:
```python
CORS(app, 
     resources={r"/*": {
         "origins": "*",
         "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
         "allow_headers": ["Content-Type", "Authorization", "Accept"],
         "supports_credentials": False,
         "max_age": 3600
     }})
```

3. Added OPTIONS to route methods:
```python
@app.route('/api/users', methods=['GET', 'POST', 'OPTIONS'])
```

## Common Issues

### Issue: "CORS preflight did not succeed"
- Cause: Browser cached old response or backend not handling OPTIONS
- Solution: Clear cache + hard refresh, or use incognito mode

### Issue: "No 'Access-Control-Allow-Origin' header"
- Cause: CORS not configured on backend
- Solution: Already fixed with Flask-CORS and @app.before_request

### Issue: OPTIONS returns 404
- Cause: Route doesn't include OPTIONS method
- Solution: Already fixed - all routes now handle OPTIONS

### Issue: OPTIONS returns 500
- Cause: Backend error in OPTIONS handler
- Solution: Check backend logs with `flyctl logs -a mixflow-backend`

## Next Steps
1. Open https://mixflowio.vercel.app/ in incognito mode
2. Try to sign up with a new user
3. Check browser DevTools Network tab for the OPTIONS request
4. If still failing, run the test-cors.html file to isolate the issue
