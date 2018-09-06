import re
import csv
from collections import Counter

def words(text): return re.findall(r'[a-zA-Z\']+', text.lower())

def bigrams(text): return re.findall(r'\b[a-zA-Z\']+\s[a-zA-Z\']+\b', text.lower())

WORDS = Counter(words(open('dialogues_text.txt').read()))

BIWORDS = Counter(bigrams(open('dialogues_text.txt').read()))
BIWORDS_filtered = {key: value for key, value in BIWORDS.items() if value > 3}

BIWORDS_mapped = {}

for line in BIWORDS_filtered:
    key = line.split(' ')[0]
    val = line.split(' ')[1]
    count = BIWORDS_filtered[line]

    if key in BIWORDS_mapped:
        BIWORDS_mapped[key].append({val, count})
    else:
        BIWORDS_mapped[key] = []
        BIWORDS_mapped[key].append({val, count})

with open('bi_gram_english.csv', 'w') as f:  # Just use 'w' mode in 3.x
    for item in BIWORDS_mapped:
        _string = "{},{}".format(item, BIWORDS_mapped[item])
        f.write("%s\n" % _string)

with open('english.csv', 'w') as f:  # Just use 'w' mode in 3.x
    w = csv.writer(f, quoting=csv.QUOTE_NONE, escapechar='\\')
    w.writerows(sorted(WORDS.items(), key=lambda x:x[1], reverse=True))