test \( 5 -ne 5 \) -o -n hello

echo "hello world\n"

(trap 'echo bye' SIGTERM ; echo hi) & wait