+++
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
date = {{ .Date }}
draft = true
tags = ["Networking", "Study Notes"]
featured_image = 'featured.png'
summary = 'Brief description of what this post covers (2-3 sentences)'
categories = ['routing']
+++

<!-- AI Content Guidelines for ngeran[io] Blog -->

## Overview
[Provide a brief introduction to the topic - what will the reader learn?]

## Background
[Explain the context and why this topic matters for JNCIE-SP preparation]

## Key Concepts
[List and explain the main technical concepts]

### Concept 1
[Detailed explanation with diagrams if needed]

### Concept 2
[Detailed explanation with configuration examples]

## Configuration Examples
```junos
# Provide practical Junos configuration examples
# Include real-world scenarios

set protocols ospf area 0.0.0.1 interface ge-0/0/0.0
```

## Verification
[Show how to verify the configuration works]

```bash
# Show verification commands
show ospf neighbor
show route protocol ospf
```

## Common Issues & Troubleshooting
[List common problems and how to solve them]

## Exam Tips
[Specific JNCIE-SP exam tips for this topic]

## Summary
[Quick recap of key points]

## References
- [Juniper Documentation](https://www.juniper.net/documentation/)
- [RFCs or other resources]

---
**AI Generation Guidelines:**
- Maintain technical accuracy
- Use clear, concise language
- Include practical examples
- Add diagrams where helpful (store in post directory)
- Focus on exam-relevant content
- Keep explanations thorough but readable
