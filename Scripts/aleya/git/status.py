import subprocess


def has_uncommitted_changes(work_dir: str = '.') -> bool:
    """
    Check if there are uncommitted git changes in the given directory.
    """
    try:
        status_output = subprocess.check_output(['git', 'status', '--porcelain'], cwd=work_dir).decode('utf-8')

        if status_output.strip():
            return True
        else:
            return False

    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Error: {e}")
