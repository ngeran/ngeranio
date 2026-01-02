# Deployment Guide - Cloudflare Pages

This guide covers deploying the ngeran[io] blog to Cloudflare Pages via GitHub integration.

## Prerequisites

- GitHub repository with blog content
- Cloudflare account with Pages access
- Hugo extended version installed locally

## Deployment Architecture

```
GitHub Push → Cloudflare Pages Build → Automatic Deployment
                   ↓
            hugo --minify
                   ↓
            public/ directory
                   ↓
            Global CDN
```

## Cloudflare Pages Setup

### 1. Connect GitHub Repository

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Go to **Workers & Pages**
3. Click **Create application** → **Pages** → **Connect to Git**
4. Select your ngeran[io] repository
5. Authorize Cloudflare access (if needed)

### 2. Configure Build Settings

In **Build settings**, use:

**Build command:**
```bash
hugo --minify
```

**Build output directory:**
```bash
public
```

**Root directory:**
```bash
/ (repository root)
```

### 3. Environment Variables (Optional)

For production builds:

```
HUGO_VERSION = 0.140.0
HUGO_ENV = production
```

### 4. Deployment Triggers

By default, Cloudflare Pages deploys:
- **On every push** to the main branch
- **On every pull request** (preview deployments)

## Testing Before Deployment

### Local Testing Checklist

```bash
# 1. Clean build
rm -rf public/ resources/
hugo --minify

# 2. Check for errors
echo $?  # Should be 0

# 3. Test locally
hugo server -D

# 4. Verify in browser
# Open http://localhost:1313
```

### Pre-Deployment Checklist

- [ ] All images are optimized (WebP format preferred)
- [ ] No draft posts have `draft = false` by mistake
- [ ] All internal links work
- [ ] External links are valid
- [ ] Mobile responsive design works
- [ ] Dark/light mode toggle works
- [ ] No console errors in browser
- [ ] Site loads quickly (test with Lighthouse)
- [ ] `.gitignore` excludes build artifacts
- [ ] No sensitive data in repository

## Deployment Workflow

### Standard Deployment

```bash
# 1. Make changes to content
vim content/routing/ospf/new-post/index.md

# 2. Test locally
./scripts/preview.sh

# 3. Commit changes
git add content/
git commit -m "Add post: OSPF Areas"
git push origin main
```

Cloudflare automatically builds and deploys within 1-2 minutes.

### Preview Deployment (Pull Request)

```bash
# 1. Create feature branch
git checkout -b feature/new-content

# 2. Make changes
git add content/
git commit -m "Add: New OSPF content"

# 3. Push to GitHub
git push origin feature/new-content

# 4. Create PR on GitHub
# Cloudflare creates preview deployment automatically
```

## Managing Deployments

### View Deployment Status

1. Go to Cloudflare Dashboard → Workers & Pages
2. Select your project
3. View **Deployments** tab
4. See build logs and status

### Rollback Deployment

If a deployment has issues:

1. Go to **Deployments** tab
2. Find previous successful deployment
3. Click **Rollback** to revert

### Custom Domain

The blog is configured for:
- **Production**: `https://ngeranio.com`

DNS is managed via Cloudflare DNS.

## Build Optimization

### Hugo Production Build

The `--minify` flag:
- Minifies HTML, CSS, JS
- Optimizes assets
- Removes whitespace
- Reduces file sizes by 30-50%

### Performance Tips

1. **Images**: Use WebP format with compression
2. **Fonts**: Use system fonts or optimized WOFF2
3. **CSS**: Tailwind purges unused styles automatically
4. **JS**: Keep JavaScript minimal and defer loading
5. **CDN**: Cloudflare automatically caches static assets

## Monitoring

### Cloudflare Analytics

After deployment, monitor:
- **Page Views**: Track traffic
- **Bandwidth**: Monitor CDN usage
- **Cache Hit Ratio**: Should be >90%
- **Error Rate**: Should be <1%

### Uptime Monitoring

Consider setting up:
- [Cloudflare Analytics](https://dash.cloudflare.com/)
- External monitoring (UptimeRobot, Pingdom)
- Alert on downtime

## Troubleshooting

### Build Failures

**Problem**: Build fails in Cloudflare

**Solutions**:
1. Check build logs in Cloudflare dashboard
2. Test locally: `hugo --minify`
3. Verify hugo.toml syntax
4. Check for missing assets/images
5. Ensure all content has valid frontmatter

### 404 Errors

**Problem**: Pages return 404 after deployment

**Solutions**:
1. Check case sensitivity of URLs
2. Verify `content/` structure
3. Ensure `index.md` files exist in directories
4. Check for typos in permalinks

### Theme Not Loading

**Problem**: Site looks unstyled

**Solutions**:
1. Verify theme is in `themes/vector/`
2. Check `.gitignore` doesn't exclude theme files
3. Ensure resources are built: `hugo --minify`
4. Clear browser cache

### Images Not Displaying

**Problem**: Images broken after deployment

**Solutions**:
1. Verify images are committed to git
2. Check image paths (relative paths work best)
3. Ensure image files are in correct directories
4. Optimize large images (<500KB recommended)

## Continuous Deployment

The blog uses **automatic deployment**:
- Push to `main` branch → Production deploy
- Pull request → Preview deploy

No manual intervention needed!

## Security Considerations

1. **No sensitive data in repo**: Use `.gitignore`
2. **HTTPS enforced**: Cloudflare provides SSL
3. **No server-side code**: Static site only
4. **Rate limiting**: Cloudflare provides DDoS protection
5. **Access logs**: Review Cloudflare analytics

## Backup Strategy

Since content is in Git:
1. **GitHub** is the primary backup
2. **Local clones** provide additional backups
3. **Cloudflare cache** is temporary, not a backup

Recommended:
```bash
# Regular backups
git clone git@github.com:yourusername/ngeranio.git backup-$(date +%Y%m%d)
```

## Performance Targets

After deployment, aim for:
- **Lighthouse Score**: >90 (Performance, Accessibility, Best Practices, SEO)
- **Load Time**: <2 seconds on 4G
- **First Contentful Paint**: <1.5 seconds
- **Time to Interactive**: <3 seconds

Test with: [Google PageSpeed Insights](https://pagespeed.web.dev/)

## Support

For deployment issues:
1. Check [Hugo documentation](https://gohugo.io/)
2. Review [Cloudflare Pages docs](https://developers.cloudflare.com/pages/)
3. Open issue in repository
4. Check build logs in Cloudflare dashboard

---

**Last Updated**: 2026-01-01
**Hugo Version**: 0.140.0+
**Cloudflare Pages**: Active
