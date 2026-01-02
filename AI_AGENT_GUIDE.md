# AI Agent Content Creation Guide

This guide provides instructions for AI agents to create and publish content on the ngeran[io] blog.

## Blog Mission

The ngeran[io] blog shares JNCIE-SP study notes and networking knowledge. The author is a network engineer studying for the JNCIE-SP certification and documents their learning journey.

## Content Focus Areas

1. **OSPF** - Open Shortest Path First protocol
2. **BGP** - Border Gateway Protocol
3. **MPLS** - Multi-Protocol Label Switching
4. **Junos** - Juniper Networks operating system
5. **Network Architecture** - Design principles and best practices

## Content Creation Workflow

### 1. Planning Phase

Before creating content, determine:
- **Topic**: Specific networking concept or protocol
- **Category**: OSPF, BGP, MPLS, or Junos
- **Target Audience**: JNCIE-SP candidates, network engineers
- **Depth**: Comprehensive coverage with practical examples
- **Prerequisites**: What knowledge should readers have?

### 2. Content Structure

Each post should follow this structure:

```markdown
+++
title = 'Descriptive Title'
date = YYYY-MM-DDTHH:MM:SS-05:00
draft = true  # Change to false when ready to publish
tags = ["Protocol", "Topic", "Juniper"]
featured_image = 'featured.png'
summary = '2-3 sentence description'
categories = ['routing']
+++

## Overview
Brief introduction

## Background/Context
Why this matters

## Key Concepts
Detailed technical explanations

## Configuration Examples
Real Junos configurations

## Verification
How to verify it works

## Troubleshooting
Common issues and solutions

## Exam Tips
JNCIE-SP specific guidance

## Summary
Key takeaways

## References
Links to documentation
```

### 3. File Organization

Create new posts using:

```bash
hugo new content/routing/{category}/{post-slug}/index.md
```

Example:
```bash
hugo new content/routing/ospf/ospf-areas/index.md
```

This creates:
```
content/
  routing/
    ospf/
      ospf-areas/
        index.md  # Main content
        featured.png  # Add a featured image
        diagram-1.png  # Additional diagrams
```

### 4. Writing Guidelines

#### Tone and Style
- **Professional but accessible**: Technical but readable
- **Practical focus**: Real-world applications
- **Exam-oriented**: Highlight JNCIE-SP relevant points
- **Accurate**: Verify all technical details

#### Code Blocks
- Use Junos CLI syntax highlighting
- Include complete configuration examples
- Show output with verification commands
- Add comments explaining key lines

```junos
# Configure OSPF area
set protocols ospf area 0.0.0.1 interface ge-0/0/0.0
set protocols ospf area 0.0.0.1 interface lo0.0 passive

# Verify configuration
user@router> show ospf neighbor
```

#### Diagrams
- Include network topology diagrams
- Use clear, simple diagrams
- Save as PNG in post directory
- Reference with `![Alt text](filename.png)`

#### Formatting
- Use headings (H2, H3) for structure
- Include bullet points for lists
- Add callout boxes for important notes
- Use tables for comparisons

### 5. Content Quality Checklist

Before marking `draft = false`:

- [ ] Title is clear and descriptive
- [ ] Summary accurately describes content
- [ ] Technical accuracy verified
- [ ] Code examples tested
- [ ] Diagrams included where helpful
- [ ] Proofread for clarity
- [ ] Tags are relevant
- [ ] Featured image added
- [ ] Internal links to related posts
- [ ] External references included

### 6. Testing Content

Before publishing:

1. **Local Preview**
   ```bash
   hugo server -D
   ```
   Visit http://localhost:1313 to preview

2. **Check Links**
   - All internal links work
   - External links are valid
   - Image paths are correct

3. **Review Rendering**
   - Code blocks display correctly
   - Diagrams load properly
   - Table of contents generates
   - Formatting looks good in both light and dark mode

### 7. Publishing

When ready to publish:

1. Update frontmatter:
   ```toml
   draft = false
   ```

2. Commit to git:
   ```bash
   git add content/
   git commit -m "Add post: [Title]"
   git push
   ```

3. Cloudflare Pages auto-deploys from GitHub

### 8. Content Ideas

Here are some suggested topics:

#### OSPF
- OSPF Areas and LSA Types
- OSPF Network Types (broadcast, point-to-point, etc.)
- OSPF Stub and NSSA Areas
- OSPF Virtual Links
- OSPF Authentication
- OSPF Route Summarization
- OSPF Cost and Metric Calculation

#### BGP
- BGP Peer Establishment and States
- BGP Attributes and Path Selection
- BGP Route Reflection
- BGP Confederations
- BGP Communities
- BGP Filtering and Route Maps
- BGP Load Sharing
- BGP Multiprotocol Extensions

#### MPLS
- MPLS Labels and Label Switching
- MPLS LDP Configuration
- MPLS VPN Architecture
- MPLS L3VPNs
- MPLS L2VPNs
- MPLS Traffic Engineering
- MPLS QoS

#### Junos
- Junos Configuration Basics
- Junos Routing Instances
- Junos Firewall Filters
- Junos Policy Options
- Junos Automation with PyEZ/NETCONF
- Junos Monitoring and Troubleshooting

### 9. Automation Scripts

AI agents can use these helper scripts:

#### Create New Post Script
```bash
#!/bin/bash
# create-post.sh

CATEGORY=$1
TITLE=$2
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

hugo new content/routing/$CATEGORY/$SLUG/index.md
echo "Post created: content/routing/$CATEGORY/$SLUG/index.md"
```

Usage:
```bash
./create-post.sh ospf "OSPF Virtual Links"
```

#### Update Drafts Script
```bash
#!/bin/bash
# publish-post.sh

# Convert draft posts to published
find content/ -name "index.md" -exec sed -i 's/draft = true/draft = false/' {} \;
```

### 10. AI Agent Best Practices

When creating content autonomously:

1. **Verify Technical Accuracy**
   - Cross-reference with Juniper documentation
   - Check against RFC standards
   - Verify configuration syntax

2. **Maintain Consistency**
   - Use established templates
   - Follow naming conventions
   - Keep similar depth across posts

3. **Add Value**
   - Include practical examples
   - Share troubleshooting tips
   - Add exam-specific insights

4. **Quality Control**
   - Test code examples
   - Preview before publishing
   - Proofread carefully

5. **Version Control**
   - Write descriptive commit messages
   - Create meaningful branches for features
   - Document major changes

## Contact

For questions about content creation, contact the blog author or open an issue in the repository.

---

**Remember**: This blog represents the author's professional journey. Quality and accuracy are paramount. Every post should add value to readers preparing for the JNCIE-SP exam or working with networking technologies.
