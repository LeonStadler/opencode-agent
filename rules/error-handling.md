# Error Handling

1. Always raise errors explicitly — never silently ignore them.
2. Use specific error types that clearly indicate what went wrong.
3. Avoid catch-all handlers that hide the root cause.
4. Error messages must be clear and actionable.
5. **No fallbacks** unless the user explicitly asks for them.
6. Fix root causes, not symptoms.
7. External API or service calls: use retries with warnings, then raise the last error.
8. Error messages must include enough context to debug: request params, response body, status codes.
9. Logging should use structured fields — do not interpolate dynamic values into log message strings.
