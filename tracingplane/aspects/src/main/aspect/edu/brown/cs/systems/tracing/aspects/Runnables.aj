package edu.brown.cs.systems.tracing.aspects;

import edu.brown.cs.systems.baggage.Baggage;
import edu.brown.cs.systems.baggage.DetachedBaggage;
import edu.brown.cs.systems.tracing.aspects.Annotations.BaggageInheritanceDisabled;

/** Instruments all runnables to add the following logic: 
 * 1. When the runnable object is created, the baggage at that point in time is saved 
 * 2. When the runnable is run, the baggage that was saved is now resumed 
 * 3. When the run method finishes, the baggage is cleared
 */
public aspect Runnables {
    private DetachedBaggage InstrumentedRunnable.constructor_baggage;
    private DetachedBaggage InstrumentedRunnable.runend_baggage;

    public void InstrumentedRunnable.rememberConstructorContext() {
        if (constructor_baggage == null)
            constructor_baggage = Baggage.fork();
    }

    public void InstrumentedRunnable.rememberRunendContext() {
        if (runend_baggage == null) {
            runend_baggage = Baggage.stop();
        }
    }

    public void InstrumentedRunnable.rejoinConstructorContext() {
        Baggage.start(constructor_baggage);
        constructor_baggage = null;
    }

    public void InstrumentedRunnable.joinRunendContext() {
        Baggage.join(runend_baggage);
    }

    before(InstrumentedRunnable r): this(r) && execution(InstrumentedRunnable+.new(..)) {
        r.rememberConstructorContext();
    }

    before(InstrumentedRunnable r): this(r) && execution(void InstrumentedRunnable+.run(..)) {
        r.rejoinConstructorContext();
    }

    after(InstrumentedRunnable r):  this(r) && execution(void InstrumentedRunnable+.run(..)) {
        r.rememberRunendContext();
    }

    // Runnable itself can't be instrumented, but any subclasses defined by the application can.
    declare parents: (!@BaggageInheritanceDisabled Runnable)+ implements InstrumentedRunnable;

}