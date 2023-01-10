#!/usr/bin/env sh

set -e

shopt -s extglob

help() {
  echo "datef"
  echo "Compare dates and output in human readable format e.g. \`2 days ago\`"
  echo
  echo "USAGE" 
  echo "\tdatef [-f <input_format>] [<input_date>] [-h]"
  echo
  echo "OPTIONS"
  echo "\t-f --format <input_format>\tTakes date compliant format e.g. \"%Y-%m-%d\"\t"
  echo "\t-h --help\t\t\tShow help"
  echo
  echo "EXAMPLES"
  echo "\tWhen current date is set to \"Sat Jan  7 12:00:00 UTC 2023\""
  echo
  # 1 hour ago
  echo "\tdatef -f %Y-%m-%dT%H:%M:%SZ 2023-01-07T11:00:00Z"
  echo "\t1 hour ago"
  echo
  # 3 days ago
  echo "\tdatef -f %Y-%m-%d 2023-01-04"
  echo "\t3 days ago"
  echo
  # 15 minutes in future
  echo "\tdatef -f %Y-%m-%dT%H:%M:%SZ 2023-01-07T13:30:00Z"
  echo "\t15 minutes in future"
  echo
  # Two dates
  echo "\tWhen two dates are given the first one is the one compared to"
  echo
  # 18 days ago
  echo "\tdatef -f %Y-%m-%d 2023-01-01 2022-12-14"
  echo "\t18 days ago"
  echo
  exit 2
}

err() {
  >&2 printf "error: %s\n" "$@"
  exit 1
}

if [ $# -eq 0 ]; then
  help
fi

dates=()
while [ $# -gt 0 ]; do
  case "$1" in
    -f|--format)
      if [ ! -z $format ]; then
        err "Format $format was already provided, got more than one format, expected one format"
      fi
      format="$2"
      shift
    ;;
    !(-*))
      dates+=("$1")
    ;;
    -h|--help)
      help
    ;;
  esac
  shift
done

dates_length="${#dates[@]}"

if [ $dates_length -eq 0 ]; then
  err "Date input was not provided"
elif [ $dates_length -gt 2 ]; then
  err "Too many input input dates given, got $dates_length, expected maximum of 2"
fi

format_date() {
  if ! date=$(date -j -f "${format}" "$1" +%s 2>&1); then
    err "$(echo "$date" | awk 'NR==1{ print }')"
  fi
  echo $(echo "$date" | grep -E '\d+$')
}

date_a=$(format_date "${dates[0]}")

# Calculate date diffs
if [ $dates_length -gt 1 ]; then
  date_b=$(format_date $date_b "${dates[1]}")
  diff=$((($date_a-$date_b)))
else
  diff=$((($(date +%s)-$date_a)))
fi

time="ago"

if [ $diff -eq 0 ]; then
  echo "Current date"
  exit 0
elif [ $diff -lt 0 ]; then
  diff=$((${diff:1}))
  time="in future"
fi

day_threshold=86400
hour_threshold=3600
minute_threshold=60
threshold=1
unit="second"

if [ $diff -gt $(($day_threshold-1)) ]; then
  threshold=$day_threshold
  unit="day"
elif [ $diff -gt $(($hour_threshold-1)) ]; then
  threshold=$hour_threshold
  unit="hour"
elif [ $diff -gt $(($minute_threshold-1)) ]; then
  threshold=$minute_threshold
  unit="minute"
fi

diff=$(($diff / $threshold))

if [ $diff -gt 1 ]; then
  pluralised="s"
fi

printf "%d %s%c %s\n" "$diff" "$unit" "$pluralised" "$time"
