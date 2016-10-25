import tensorflow as tf

print("Hello %s" % tf)

#with open ('/runfiles/examples/tf.runfiles/baz.txt', 'a') as f:
with open ('/rules_docker/baz.txt', 'a') as f:
    f.write ('hi there\n')
    print("Wrote to %s" % f)
