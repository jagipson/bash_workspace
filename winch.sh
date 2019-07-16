# function that sends the current shell process a WINCH sig
winch ()
{
  kill -WINCH $$
}
