# ✅ Deployment Checklist

Use this checklist to deploy the complete system.

## 📋 Pre-Deployment

- [ ] Fly.io account created (https://fly.io/app/sign-up)
- [ ] Vercel account created (https://vercel.com/signup)
- [ ] Fly CLI installed (`curl -L https://fly.io/install.sh | sh`)
- [ ] Vercel CLI installed (`npm i -g vercel`)
- [ ] Mac has Python 3 installed
- [ ] Mac has pip3 installed
- [ ] Agent servers tested locally (`./agent-control.sh status`)

## 🚀 Step 1: Deploy Fly.io Broker

- [ ] Navigate to `fly-broker` directory
- [ ] Login to Fly.io: `flyctl auth login`
- [ ] Launch app: `flyctl launch --name agent-broker --region iad`
- [ ] Deploy: `flyctl deploy`
- [ ] Get URL: `flyctl info` (note the hostname)
- [ ] Test health: `curl https://agent-broker.fly.dev/api/health`
- [ ] Verify response: `{"status":"ok","workers":{"count":0}}`

**Broker URL**: `https://agent-broker.fly.dev`

## 📱 Step 2: Deploy Vercel UI

- [ ] Navigate to `vercel-ui` directory
- [ ] Login to Vercel: `vercel login`
- [ ] Deploy preview: `vercel`
- [ ] Add environment variable: `vercel env add BROKER_URL production`
  - [ ] Enter: `https://agent-broker.fly.dev`
- [ ] Deploy production: `vercel --prod`
- [ ] Get URL from output (note the URL)
- [ ] Open URL in browser
- [ ] Verify UI loads
- [ ] Check worker status shows "0 online"

**Vercel URL**: `https://your-app.vercel.app`

## 🖥️ Step 3: Start Mac Worker

- [ ] Navigate to `mac-worker` directory
- [ ] Install dependencies: `pip3 install -r requirements.txt`
- [ ] Create `.env` file:
  ```bash
  cat > .env << EOF
  BROKER_URL=https://agent-broker.fly.dev
  CPU_LIMIT=40
  RAM_LIMIT=40
  POLL_INTERVAL=5
  EOF
  ```
- [ ] Make script executable: `chmod +x start-worker.sh`
- [ ] Start agent servers: `cd ../../ && ./agent-control.sh start-all`
- [ ] Verify servers running: `./agent-control.sh status`
- [ ] Start worker: `cd simple-broker-system/mac-worker && ./start-worker.sh`
- [ ] Verify registration: Check logs for "✅ Registered as worker"
- [ ] Verify polling: Check logs for "📡 Polling for tasks"

## 🧪 Step 4: Test End-to-End

### Test from Phone
- [ ] Open Vercel URL on phone
- [ ] Verify worker shows as online
- [ ] Check CPU/RAM usage displays
- [ ] Select project: "diaperstops"
- [ ] Enter task: "echo Hello from my phone!"
- [ ] Submit task
- [ ] Watch status change: pending → running → completed
- [ ] Verify result displays
- [ ] Check duration and usage stats

### Test from Terminal
- [ ] Submit task via curl:
  ```bash
  curl https://agent-broker.fly.dev/api/submit \
    -H "Content-Type: application/json" \
    -d '{"project":"diaperstops","task":"echo test"}'
  ```
- [ ] Note the taskId from response
- [ ] Check status:
  ```bash
  curl https://agent-broker.fly.dev/api/status/TASK_ID
  ```
- [ ] Verify task completes

### Test Resource Limits
- [ ] Check worker logs for resource usage
- [ ] Verify CPU stays under 40%
- [ ] Verify RAM stays under 40%
- [ ] Submit heavy task to test limits
- [ ] Monitor system resources: `top` or Activity Monitor

## 📊 Step 5: Monitoring Setup

- [ ] Bookmark Vercel URL on phone
- [ ] Add to phone home screen (optional)
- [ ] Set up worker log monitoring:
  ```bash
  tail -f mac-worker/worker.log
  ```
- [ ] Set up broker log monitoring:
  ```bash
  flyctl logs
  ```
- [ ] Test health endpoint:
  ```bash
  curl https://agent-broker.fly.dev/api/health | jq
  ```

## 🔧 Step 6: Configuration Tuning

- [ ] Test different CPU limits (20%, 30%, 50%)
- [ ] Test different RAM limits
- [ ] Adjust poll interval if needed
- [ ] Test with multiple projects
- [ ] Verify all 5 agent servers work

## 📱 Step 7: Mobile Optimization

- [ ] Test on different phone sizes
- [ ] Test in portrait and landscape
- [ ] Verify touch targets are large enough
- [ ] Test real-time updates
- [ ] Check battery usage during polling

## 🐛 Step 8: Troubleshooting

If worker not connecting:
- [ ] Check broker URL in .env
- [ ] Ping broker: `ping agent-broker.fly.dev`
- [ ] Check broker health: `curl https://agent-broker.fly.dev/api/health`
- [ ] Check worker logs: `tail -f worker.log`
- [ ] Verify agent servers: `./agent-control.sh status`

If tasks not executing:
- [ ] Check agent servers are running
- [ ] Test agent server directly: `curl http://localhost:8001/`
- [ ] Check worker logs for errors
- [ ] Verify task format is correct

If high resource usage:
- [ ] Lower CPU_LIMIT in .env
- [ ] Lower RAM_LIMIT in .env
- [ ] Restart worker
- [ ] Monitor with: `top` or Activity Monitor

## 💰 Step 9: Cost Verification

- [ ] Check Fly.io dashboard for costs
- [ ] Verify spot instance pricing (~$1.94/month)
- [ ] Check Vercel dashboard (should be $0)
- [ ] Confirm total cost under $2/month

## 📚 Step 10: Documentation

- [ ] Read README.md for overview
- [ ] Read DEPLOY.md for details
- [ ] Read QUICK_START.md for reference
- [ ] Bookmark ARCHITECTURE.md
- [ ] Save CHECKLIST.md for future deployments

## 🎉 Completion Checklist

- [ ] Broker deployed and healthy
- [ ] UI deployed and accessible
- [ ] Worker running and registered
- [ ] End-to-end test passed
- [ ] Resource limits working
- [ ] Monitoring set up
- [ ] Phone bookmarked
- [ ] Documentation reviewed

## 🚀 Next Steps

- [ ] Submit real tasks from phone
- [ ] Monitor resource usage over time
- [ ] Adjust limits as needed
- [ ] Add more workers (optional)
- [ ] Set up alerts (optional)

## 📝 Notes

**Broker URL**: ___________________________________

**Vercel URL**: ___________________________________

**Worker ID**: ___________________________________

**Deployment Date**: ___________________________________

**Issues Encountered**: 

___________________________________

___________________________________

___________________________________

## ✅ Sign-Off

- [ ] System fully deployed
- [ ] All tests passed
- [ ] Documentation complete
- [ ] Ready for production use

**Deployed by**: ___________________________________

**Date**: ___________________________________

---

🎉 Congratulations! Your resource-limited agent system is now live!

Submit tasks from your phone and watch them execute on your Mac with real-time CPU/RAM monitoring for just $2/month.
