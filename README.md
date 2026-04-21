# Projects Overview

All repositories cloned and configured with Makefiles for easy development.

## 🤖 Agent Server System

All projects now have local agent servers for task execution and process management!

**Quick Start:**
```bash
# Start all agent servers
./agent-control.sh start-all

# Check status
./agent-control.sh status

# Execute a task
curl -X POST http://localhost:8001/execute -d '{"task":"run tests"}'
```

**Documentation:**
- [Complete Guide](AGENT_SERVERS_GUIDE.md) - Full documentation
- [Quick Reference](AGENT_QUICK_REF.md) - Cheat sheet

**Features:**
- ✅ Local HTTP API for each project
- ✅ Integrates with Kiro for task execution
- ✅ Process management (start/stop/kill)
- ✅ Machine-agnostic (Linux, Mac, Windows)
- ✅ Mobile-friendly (trigger from phone)
- ✅ Zero cost (runs locally)

## Projects

1. **mixflow.io** - React app with Material-UI
2. **diaperstops.com** - Full-stack app (Backend + Android + iOS)
3. **renovation-workflow** - Full-stack renovation management (Backend + Android)
4. **thriveinterview** - Ruby coding challenge
5. **reno-app** - Renovation app (empty repo)
6. **hynoticworld** - Hypnotic world app (empty repo)
7. **android-app-template** - Android Kotlin template
8. **templates** - Project templates collection
9. **ClimateWardrobe** - Climate-based wardrobe app
10. **translator** - Chrome extension for translation

## Quick Start

Each project has a Makefile with standard commands:

```bash
cd <project-name>
make install    # Install dependencies
make dev        # Start development server
make build      # Build for production
make clean      # Clean build artifacts
make docker-build   # Build Docker image
make docker-push    # Push to Proton Drive via rclone
```

## Jira & Slack Integration

Run the integration setup script:
```bash
./setup-integrations.sh
```

This will guide you through:
- Setting up Jira Git Integration
- Creating Slack channels for each project
- Configuring smart commits
- Installing git hooks

### Smart Commits

Use Jira ticket references in commits:
```bash
git commit -m "PROJ-123 #comment Fixed bug"
git commit -m "PROJ-456 #close Completed feature"
git commit -m "PROJ-789 #time 2h Working on API"
```

## Docker & Rclone

Upload Docker images to Proton Drive:
```bash
python3 rclone-setup.py ./Dockerfile docker-images/project-name/
```

Or use Makefile:
```bash
make docker-push
```

## Installation Requirements

- Node.js v20.19.2
- npm 9.2.0
- Docker 26.1.5
- Java 21 (OpenJDK)
- Python 3.13.5
- rclone (for Proton Drive uploads)

## Android Development

For Android projects, ensure Android SDK is installed:
```bash
# Download Android command line tools
# Set ANDROID_HOME environment variable
# Install required SDK packages
```

## Next Steps

1. Configure rclone for Proton Drive: `rclone config`
2. Set up Jira Git Integration in your Jira workspace
3. Create Slack channels for each project
4. Install dependencies in each project: `make install`
5. Start developing!
