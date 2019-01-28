# nginx-vs-haproxy

## Start the Environment

```bash
./start-env.sh
```

## HAProxy

Use <http://localhost:9001> for HAProxy proxy'ing. Can go to <http://localhost:9001/stats> for the stats page.

## Nginx

Use <http://localhost:9002> for the Nginx proxy'ing.

## Apache Benchmark

### ab test haproxy endpoint
```
$ ab -n 100000 -c 1000 -r -d http://localhost:9001/
```
### ab test nginx endpoint
```
$ ab -n 100000 -c 1000 -r -d http://localhost:9002/
```
