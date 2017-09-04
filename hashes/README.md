Transcription of some of the code from [jamesroutley/write-a-hash-table](https://github.com/jamesroutley/write-a-hash-table). Incomplete as far as the entire code is concerned but does a good job of demonstrating how to avoid the GC and make things type safe with the help of D's templating facilities.

To run the toy example making use of the hash table run

```
dmd -betterC main.d types.d tests.d && ./main
```

If you want to make changes and run the unit tests

```
dmd -main -unittest tests.d types.d && ./tests
```
