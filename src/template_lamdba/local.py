from main import handler

event = {
  "key1": "value1",
  "key2": "value2",
  "key3": "value3"
}

def run_local():
    handler(event, None)

run_local()  