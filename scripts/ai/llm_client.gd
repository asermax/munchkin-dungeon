class_name LLMClient
extends Node

## Simple OpenAI-compatible API client for z.ai GLM.
## Each request is stateless — caller provides the full message array.

signal response_received(content: String)
signal request_failed(error: String)

const DEFAULT_API_URL: String = "https://api.z.ai/api/paas/v4/chat/completions"
const DEFAULT_MODEL: String = "glm-4.7-flash"

@export var api_url: String = DEFAULT_API_URL
@export var api_key: String = ""
@export var model: String = DEFAULT_MODEL
@export var temperature: float = 0.7
@export var max_tokens: int = 2048

var _http: HTTPRequest


func _ready() -> void:
	_http = HTTPRequest.new()
	_http.timeout = 30.0
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


## Send a chat completion request.
## messages: Array of {role: String, content: String}
func send(messages: Array) -> void:
	if api_key == "":
		request_failed.emit("API key not set")
		return

	var body := {
		"model": model,
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"stream": false,
	}

	var headers := PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key,
	])

	var json := JSON.stringify(body)
	var err := _http.request(api_url, headers, HTTPClient.METHOD_POST, json)

	if err != OK:
		request_failed.emit("HTTPRequest error: " + str(err))


## Convenience: send a single user prompt with optional system message.
func prompt(user_message: String, system_message: String = "") -> void:
	var messages: Array = []

	if system_message != "":
		messages.append({"role": "system", "content": system_message})

	messages.append({"role": "user", "content": user_message})
	send(messages)


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("HTTP result error: " + str(result))
		return

	if response_code < 200 or response_code >= 300:
		request_failed.emit("HTTP " + str(response_code) + ": " + body.get_string_from_utf8())
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())

	if parsed == null:
		request_failed.emit("Failed to parse JSON response")
		return

	var choices: Array = parsed.get("choices", [])

	if choices.size() == 0:
		request_failed.emit("No choices in response")
		return

	var content: String = choices[0].get("message", {}).get("content", "")
	response_received.emit(content)
