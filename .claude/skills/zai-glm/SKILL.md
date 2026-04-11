---
name: zai-glm
description: Use the z.ai GLM API client for LLM-powered AI. Use when implementing the LLM brain, serializing game state, parsing responses, or debugging API calls.
---

# z.ai GLM API Client

## API Details

- **Endpoint**: `https://api.z.ai/api/paas/v4/chat/completions`
- **Auth**: `Authorization: Bearer API_KEY`
- **Format**: OpenAI-compatible (same request/response schema)
- **Free models**: `glm-4.7-flash`, `glm-4.5-flash`
- **CORS**: Supported natively — direct browser WASM calls work

## Client Usage (LLMClient)

The client is at `scripts/ai/llm_client.gd`:

```gdscript
# Create and configure
var llm := LLMClient.new()
llm.api_key = "your-key"          # or load from config.env
llm.model = "glm-4.7-flash"       # free model
llm.temperature = 0.7
llm.max_tokens = 2048
add_child(llm)                     # needs to be in scene tree (uses HTTPRequest)

# Connect signals
llm.response_received.connect(_on_response)
llm.request_failed.connect(_on_error)

# Send messages
llm.send([
    {"role": "system", "content": "You are a tactical AI..."},
    {"role": "user", "content": "Game state JSON here..."}
])

# Or use convenience method for single prompts
llm.prompt("What action do you take?", "You are a tactical commander.")
```

## Response Format

Signals, not await:
- `response_received(content: String)` — the text content from `choices[0].message.content`
- `request_failed(error: String)` — HTTP errors, JSON parse errors, empty responses

## API Key Management

- Stored in `config.env` (NOT `.env` — dotfiles aren't exported to WASM)
- Format: `ZAI_API_KEY=your-key-here`
- Load with `FileAccess.open("res://config.env", FileAccess.READ)` → parse lines
- Included in WASM export via `include_filter="config.env"` in export_presets.cfg
