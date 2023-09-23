from aleya.git import has_uncommitted_changes


def check_uncommitted_changes():
    try:
        if has_uncommitted_changes():
            print("There are uncommitted changes in the git repository.")
            return 1
        else:
            return 0

    except RuntimeError as e:
        print(e)
        return 1


if __name__ == "__main__":
    exit_code = check_uncommitted_changes()
    exit(exit_code)
