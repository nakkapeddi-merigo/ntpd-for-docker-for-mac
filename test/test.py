import time
print('Running test (may take up to 30s)...', flush=True)
t0 = t1 = time.time()
for _ in range(6):
    te = t1 + 5
    while t1 < te:
        assert t1 >= t0, "t0={}, t1={}".format(t0, t1)
        t0, t1 = t1, time.time()
    print('...', flush=True)
print('OK', flush=True)
