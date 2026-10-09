---
name: review
description: Adversarially reviews a change and reports findings for a user to weigh.
model: gpt-6-sol  # Keep different from implement's model, so review is independent.
tools: ["read", "search", "execute", "web", "todo"]
user-invocable: false
---
