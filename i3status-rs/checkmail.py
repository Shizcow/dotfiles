import sys, imaplib
conn = imaplib.IMAP4_SSL(sys.argv[1])

try:
    (retcode, capabilities) = conn.login(sys.argv[2], sys.argv[3])
except:
    print(sys.exc_info()[1])
    sys.exit(1)

conn.select(readonly=1) # Select inbox or default namespace
(retcode, messages) = conn.search(None, '(UNSEEN)')
if retcode == 'OK':
    print('0' if messages[0] == b'' else len(messages[0].split(b' ')))

conn.close()
