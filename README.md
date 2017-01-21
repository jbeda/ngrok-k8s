# ngrok-k8s

This is a simple Docker container that can be used to launch [ngrok](https://ngrok.com/) in a Kuberntes cluster to surface either services or other pods directly.

This is strictly intended for debug/dev type scenarios.

## Running in Kubernetes

```
kubectl run --restart=Never \
  -t -i --rm \
  ngrok --image=gcr.io/kuar-demo/ngrok \
  -- http my-service:8080
```

Some explanation:

* `--restart=Never` This says "I just want a Pod".  If you don't specify this you get a Deployment.  We don't need that.
* `-t -i --rm` These options state that I want an interactive tty.  Also clean things up when I'm done.
* `--` Says "everything past this are arguments for the container".  
* `http my-service:8080` These are arguments to the ngrok utility.  This says "create an HTTP forwarding tunnel to `my-service:8080`"

## Notes

You can password protect this tunnel easily with `auth='username:password'`.  You can make this https only with `--bind-tls=true`.  See the ngrok docs for more options.

**NOTE** Using TLS tunnels for secure services (e.g. kubernetes api) you need a [pro or business plan](https://ngrok.com/product#pricing)

There is nothing Kubernetes specific (yet) in the container here.  This is really a super simple container with just ngrok in it.  I created a separate version just for this README.

Why not `kubectl port-forward`?  First, `port-forward` [doesn't support targetting Services](https://github.com/kubernetes/kubernetes/issues/15180).  Second, you may want this to be available beyond your local machine.

Why not `kubectl proxy`?  This will modify/rewrite HTTP and can get a little wacky.  It also requires your browser to auth to the API server -- something that may not be easy if you aren't using password auth.
