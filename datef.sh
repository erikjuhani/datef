#!/usr/bin/env sh

set -e

help() {
  print "datef"
  print "Compare dates and output in human readable format e.g. \`2 days ago\`"
  print
  print "USAGE"
  print "\tdatef [-f <input_format>] [<input_date>] [-h]"
  print
  print "OPTIONS"
  print "\t-f --format <input_format>\tTakes date compliant format e.g. \"%Y-%m-%d\""
  print "\t-h --help\t\t\tShow help"
  print
  print "EXAMPLES"
  print "\tWhen current date is set to \"Sat Jan  7 12:00:00 UTC 2023\""
  print
  print "\tdatef -f %Y-%m-%dT%H:%M:%SZ 2023-01-07T11:00:00Z"
  print "\t1 hour ago"
  print
  print "\tdatef -f %Y-%m-%d 2023-01-04"
  print "\t3 days ago"
  print
  print "\tdatef -f %Y-%m-%dT%H:%M:%SZ 2023-01-07T12:15:00Z"
  print "\t15 minutes in future"
  print
  print "\tWhen two dates are given the first one is the one compared to"
  print
  print "\tdatef -f %Y-%m-%d 2022-12-14 2023-01-01 "
  print "\t18 days ago"
  print
  exit 2
}

print() {
  printf "%b\n" "$@"
}

err() {
  printf >&2 "error: %s\n" "$@"
  exit 1
}

if [ $# -eq 0 ]; then
  help
fi

format_date() {
  case "$(uname -s)" in
    "Darwin") set -- -j -f "$1" "$2" ;;
    "Linux") set -- -D "$1" -d "$2" ;;
  esac

  if ! date=$(date "$@" +%s 2>&1); then
    err "$(printf "%s" "${date}" | awk 'NR==1{ print }')"
  fi
  printf "%s" "$(printf "%s" "${date}" | grep -E '\d+$')"
}

datef() {
  # parse flags and date input arguments
  while [ $# -gt 0 ]; do
    case "$1" in
    -f | --format)
      [ -n "${date_format}" ] && err "Format ${date_format} was already provided, got more than one format, expected one format"
      date_format="$2"
      shift
      ;;
    -h | --help) help ;;
    -*)
      printf "Flag %s provided but not defined\n\n" "$1"
      help
      ;;
    *)
      [ "$#" -gt 2 ] && err "Too many input dates given, got $# expected maximum of 2"
      [ -z "${date_a}" ] && date_a="$(format_date "${date_format}" "$1")"
      [ -z "${date_b}" ] && [ -n "$2" ] && date_b="$(format_date "${date_format}" "$2")"
      ;;
    esac
    shift
  done

  # validate that at least 1 input date was given
  [ -z "${date_a}" ] && err "Date input was not provided"

  date_b="${date_b:-$(date +%s)}"
  diff="$((date_b - date_a))"

  [ "${diff}" -eq 0 ] && print "Current date" && exit

  if [ "${diff}" -lt 0 ]; then
    diff="$(printf '%s' "${diff}" | cut -c 2-)"
    readonly time="in future"
  else
    readonly time="ago"
  fi

  readonly day_threshold=86400
  readonly hour_threshold=3600
  readonly minute_threshold=60

  if [ "${diff}" -gt "$((day_threshold - 1))" ]; then
    readonly threshold="${day_threshold}"
    readonly unit="day"
  elif [ "${diff}" -gt "$((hour_threshold - 1))" ]; then
    readonly threshold="${hour_threshold}"
    readonly unit="hour"
  elif [ "${diff}" -gt "$((minute_threshold - 1))" ]; then
    readonly threshold="${minute_threshold}"
    readonly unit="minute"
  fi

  diff="$((diff / ${threshold:-1}))"

  [ "$diff" -gt 1 ] && readonly pluralised="s"

  printf "%d %s%c %s\n" "${diff}" "${unit-second}" "${pluralised}" "${time}"
}

datef "$@"
