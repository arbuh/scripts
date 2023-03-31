#!/bin/bash

if [ -z "$1" ]; then
  echo "Please give a question."
  exit 1
fi

if [ "$#" -gt 2 ]; then
    echo "Error: The number of arguments should not exceed 2. Make sure the question string is escaped with quotes."
    echo "Usage: $0 [your question to ChatGPT] [an optional path to a file which content should be attached to the question]"
    exit 1
fi

question="$1"
path_to_file="$2"
endpoint="https://api.openai.com/v1/chat/completions"
temperature=0.7

if [ -z "$path_to_file" ]; then
    prompt="$question"
else
    file_content=$(cat "$path_to_file")
    prompt="$question: $file_content"
fi

request=$(jq -n --arg prompt "$prompt" --argjson temperature "$temperature" '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": $prompt}],
    "temperature": $temperature
}')

response=$(curl -s -X POST "$endpoint" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$request")

content=$(jq -n --arg json "$response" -r '($json|fromjson|.choices[0].message.content)')


processed_content=$(echo "$content" | xclip -selection clipboard -f)
echo "$processed_content"

