# Deployment Guide - Fly.io & Vercel

## Prerequisites

Install CLIs:
```bash
# Install Fly.io CLI
curl -L https://fly.io/install.sh | sh
export PATH="$HOME/.fly/bin:$PATH"

# Install Vercel CLI
npm install -g vercel

# Login to services
fly auth login
vercel login
```

## Deploy Backends to Fly.io

### 1. Mixflow.io Backend (Flask/Python)
```bash
cd projects/mixflow.io/backend
fly launch --no-deploy
fly secrets set DATABASE_URL="your-db-url"
fly deploy
```

### 2. DiaperStops Backend (Java)
```bash
cd projects/diaperstops.com/backend
fly launch --no-deploy
fly secrets set DATABASE_URL="your-db-url"
fly deploy
```

### 3. Hynoticworld Backend (Node.js)
```bash
cd projects/hynoticworld
npm install
fly launch --no-deploy
fly deploy
```

## Deploy Frontends to Vercel

### 1. Mixflow.io Frontend (React)
```bash
cd projects/mixflow.io/web/mixflow.io
vercel --prod
# Set environment variable: VITE_API_URL=https://mixflow-backend.fly.dev
```

### 2. DiaperStops Frontend
```bash
cd projects/diaperstops.com/web
vercel --prod
# Set environment variable: VITE_API_URL=https://diaperstops-backend.fly.dev
```

### 3. Renovation Workflow Frontend
```bash
cd projects/renovation-workflow/backend/react-frontend
vercel --prod
```

## Quick Deploy Commands

### All Backends
```bash
# From projects directory
for backend in mixflow.io/backend diaperstops.com/backend hynoticworld; do
  cd $backend
  fly deploy
  cd -
done
```

### All Frontends
```bash
# From projects directory
for frontend in mixflow.io/web/mixflow.io diaperstops.com/web; do
  cd $frontend
  vercel --prod
  cd -
done
```

## Environment Variables

### Fly.io Secrets
```bash
fly secrets set DATABASE_URL="postgresql://..."
fly secrets set JWT_SECRET="your-secret"
fly secrets set AWS_ACCESS_KEY_ID="..."
fly secrets set AWS_SECRET_ACCESS_KEY="..."
```

### Vercel Environment Variables
```bash
vercel env add VITE_API_URL production
vercel env add VITE_AUTH_DOMAIN production
```

## Monitoring

### Fly.io
```bash
fly status
fly logs
fly scale show
```

### Vercel
```bash
vercel ls
vercel logs <deployment-url>
```

## Custom Domains

### Fly.io
```bash
fly certs add api.yourdomain.com
```

### Vercel
```bash
vercel domains add yourdomain.com
```

## Scaling

### Fly.io
```bash
# Scale up
fly scale count 2

# Scale memory
fly scale memory 512

# Auto-scaling (already configured in fly.toml)
```

### Vercel
- Automatic scaling included
- Configure in project settings

## Rollback

### Fly.io
```bash
fly releases
fly deploy --image <previous-version>
```

### Vercel
```bash
vercel rollback
```

## Cost Optimization

### Fly.io
- Free tier: 3 shared-cpu-1x VMs with 256MB RAM
- Auto-stop/start configured for low traffic
- Scale to 0 when idle

### Vercel
- Free tier: Unlimited deployments
- Hobby plan: $20/month for production use

## Troubleshooting

### Fly.io Issues
```bash
# Check logs
fly logs --app mixflow-backend

# SSH into machine
fly ssh console

# Restart app
fly apps restart mixflow-backend
```

### Vercel Issues
```bash
# Check deployment logs
vercel logs

# Redeploy
vercel --prod --force
```

## CI/CD Integration

### GitHub Actions for Fly.io
Add to `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Fly.io
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

### GitHub Actions for Vercel
```yaml
name: Deploy to Vercel
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
```

## Next Steps

1. Set up custom domains
2. Configure SSL certificates
3. Set up monitoring and alerts
4. Configure backup strategies
5. Implement CI/CD pipelines
