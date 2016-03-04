## TracingPlane - Baggage Client

The `tracingplane/client` project contains our reference implementation of Baggage.  Baggage is a generic container of key-value pairs designed to be propagated alongside requests as they execute in a system.  Each request "owns" a baggage.  When a request is running in a thread, its baggage resides in a thread local variable.  The static `BaggageContents` API provides methods to access the current request's baggage -- to put or get key-value pairs.

The purpose of baggage is to provide a communication channel for request in a system, even if they traverse process, machine, or application boundaries.  Baggage is supposed to follow a request anywhere it goes.  If some k-v pair (x, y) is put in the baggage somewhere during a request's execution, then the k-v pair (x, y) will be accessible later in the request's execution.  It's like a different kind of thread local storage that persists across execution boundaries.

In order to provide the abstraction of Baggage, some manual intervention is required on the part of a system developer: when a request's execution splits into multiple concurrent branches -- eg, if it starts a new thread -- the current baggage must be copied and passed to the new thread.  The concurrent branches of the execution now, logically, have their own Baggage instances, stored in their respective thread local storage.  The static `Baggage` API provides methods for creating a copy of the current baggage into a `DetachedBaggage` form that can be passed to a new thread.  Changes made to Baggage in one thread will *not* be seen by other threads, even if they are part of the same request.

If multiple concurrent branches of an execution logically join -- eg, if Thread.join() is called -- then the baggage from the other thread should be copied back to the current thread and its contents merged back into the current thread's baggage.  The static `Baggage` API provides methods for doing this.

When a request makes a call over the network, the current baggage must be serialized and included with the request (for example, in its headers), so that the when the receiver picks up the request, it can also deserialize the baggage and set it in the processing thread.  The `DetachedBaggage` provides serialization methods to do this.

This project provides the static APIs for propagating baggage alongside a request during its execution, and for accessing its contents.  See [Adding Baggage To Your System](docs/tutorials/baggage.html) and [Using Baggage Yourself](docs/tutorials/tracingapplication.html) for tutorials on how to add Baggage to your system and how to use Baggage in an application.