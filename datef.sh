#!/usr/bin/env sh

shopt -s extglob

help() {
  echo "datef"
  echo "Compare dates and output in human readable format e.g. \`2 days ago\`"
  echo
  echo "USAGE" 
  echo "\tdatef [-f <input_format> <input_date>] [-s] [-h]"
  echo
  echo "OPTIONS"
  echo "\t-f --format <input_format>\tTakes date compliant format e.g. \"%Y-%m-%d\"\t"
  echo "\t-s --silent\t\t\tError messages are not displayed only output"
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
  echo "\tdatef -f %Y-%m-%d 2023-01-01 -f %Y/%m/%d 2022/12/14"
  echo "\t18 days ago"
  exit 2
}

SILENT=0

err() {
  if [ $SILENT == 0 ]; then
    printf "error: %s\n" "$@"
  fi
  exit 1
}

if [ $# -eq 0 ]; then
  help
fi

dates=()
formats=()

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--silent)
      SILENT=1
      shift
    ;;
    -f|--format)
      formats+=("$2")
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
  err "date input was not provided"
elif [ $dates_length -gt 2 ]; then
  err "too many input input dates given, got $dates_length, expected maximum of 2"
elif [ $dates_length -ne "${#formats[@]}" ]; then
  err "too many formats given, got ${#formats[@]}, expected $dates_length"
fi

# TODO: check if provided_date is not a number
# this usually means that we have extraneous characters in the input date
# set the seconds to the provided_date variable instead
# if this is not done the diff comparison will fail since we cannot make
# arithmetic operations between string and number
if ! date_a=$(date -j -f "${formats[0]}" "${dates[0]}" +%s 2>&1); then
  err "$(echo "$date_a" | awk 'NR==1{ print }')"
  exit 1
fi

# Calculate date diffs
if [ $dates_length -gt 1 ]; then
  if ! date_b=$(date -j -f "${formats[1]}" "${dates[1]}" +%s 2>&1); then
    err "$(echo "$date_b" | awk 'NR==1{ print }')"
    exit 1
  fi
  diff=$((($date_a-$date_b)))
else
  diff=$((($(date +%s)-$date_a)))
fi

t="ago"

if [ $diff -eq 0 ]; then
  echo "Current date"
  exit 0
elif [ $diff -lt 0 ]; then
  diff=$((${diff:1}))
  t="in future"
fi

day_threshold=86400
hour_threshold=3600
minute_threshold=60
threshold=1
time="second"

if [ $diff -gt $(($day_threshold-1)) ]; then
  threshold=$day_threshold
  time="day"
elif [ $diff -gt $(($hour_threshold-1)) ]; then
  threshold=$hour_threshold
  time="hour"
elif [ $diff -gt $(($minute_threshold-1)) ]; then
  threshold=$minute_threshold
  time="minute"
fi

diff=$(($diff / $threshold))

if [ $diff -gt 1 ]; then
  pluralised="s"
fi

printf "%d %s%c %s\n" "$diff" "$time" "$pluralised" "$t"
