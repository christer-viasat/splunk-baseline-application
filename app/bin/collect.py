import sys
import json


def get_data():
    # Fetch from external source (API, file, DB, etc.)
    return {}


def main():
    data = get_data()
    print(json.dumps(data))
    sys.stdout.flush()


if __name__ == "__main__":
    main()
