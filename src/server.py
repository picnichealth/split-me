from flask import abort, Flask, render_template, request, send_file
from os import path
from random import random
from math import ceil
from zipfile import ZipFile
import tempfile
import subprocess
app = Flask(__name__)

@app.route('/')
def main():
    return render_template('index.html')

original = 'original.pdf'
a = 'start.pdf'
b = 'end.pdf'
output = 'output.zip'

@app.route('/split/<hash>', methods=['POST'])
def split(hash):
    f = request.files['pdf']
    page = int(request.args.get('page')) if request.args.get('page') else None

    with tempfile.TemporaryDirectory() as tmpdir:
        # Save original file
        f.save(path.join(tmpdir, 'original.pdf'))

        # Get number of pages
        cmd = f"pdftk {original} dump_data | grep NumberOfPages | awk '{{print $2}}'"
        with subprocess.Popen(cmd,
                              cwd=tmpdir,
                              shell=True,
                              stdin=subprocess.PIPE,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT,
                              close_fds=True) as proc:
            try:
                num_pages = int(proc.stdout.read())
            except ValueError:
                return abort(400)

        if not page:
            # Choose a random page if none specified
            page = ceil(random() * max(1, num_pages - 1))
        else:
            # Force page to be in valid bounds
            page = min(max(page, 1), num_pages)

        if page == num_pages:
            # If page is at or after num_pages, there's nothing to split; just return the original
            filesToZip = [original]
        else:
            # Split PDF
            subprocess.call(['pdftk', original, 'cat', f'1-{page}', 'output', a], cwd=tmpdir)
            subprocess.call(['pdftk', original, 'cat', f'{page + 1}-end', 'output', b], cwd=tmpdir)
            # Reverse order so it appears in the order we want it
            filesToZip = [b, a]

        with ZipFile(path.join(tmpdir, output), 'w') as z:
            for f in filesToZip:
                z.write(path.join(tmpdir, f), arcname=f)

        # Return zip file
        return send_file(path.join(tmpdir, output),
                         mimetype='application/zip',
                         as_attachment=True,
                         attachment_filename=output)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)
