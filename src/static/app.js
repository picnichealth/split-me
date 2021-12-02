const form = document.forms['pdf-form'];

const fileInput = document.getElementById('pdf-input'),
      pageInput = document.getElementById('page-input'),
      splitButton = document.getElementById('split'),
      luckyButton = document.getElementById('lucky');

const blobSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice,
      chunkSize = 2097152; // Read in chunks of 2MB

function getFileHash(file) {
  return new Promise((resolve, reject) => {
    const chunks = Math.ceil(file.size / chunkSize),
          spark = new SparkMD5.ArrayBuffer(),
          fileReader = new FileReader();

    var currentChunk = 0;
    fileReader.onload = e => {
      spark.append(e.target.result); // Append array buffer
      currentChunk++;

      if (currentChunk < chunks) {
        loadNext();
      } else {
        resolve(spark.end()); // compute hash
      }
    };

    fileReader.onerror = reject;

    function loadNext() {
      const start = currentChunk * chunkSize,
            end = ((start + chunkSize) >= file.size) ? file.size : start + chunkSize;

      fileReader.readAsArrayBuffer(blobSlice.call(file, start, end));
    }

    loadNext();
  });
}

function splitFile(file, hash, page) {
  const formData = new FormData();

  formData.append('pdf', file);

  const url = `/split/${hash}` + (page ?
        `?page=${page}` : '');

  return fetch(url, {
    method: 'POST',
    body: formData
  })
    .then(response => response.blob())
    .then(blob => {
      const blobUrl = URL.createObjectURL(blob);

      const link = document.createElement('a');
      link.href = blobUrl;
      link.download = 'output.zip';
      link.style.display = 'none';

      document.body.appendChild(link);

      link.click();

      document.body.removeChild(link);
    })
    .catch(error => {
      console.error(error);
    });
}

function split(file, page) {
  return getFileHash(file)
    .then(hash => splitFile(file, hash, page));
}

splitButton.addEventListener('click', e => {
  e.preventDefault();

  const file = fileInput.files[0],
        page = pageInput.value;

  if (!(file && page)) {
    alert("You can't expect me to split a file without both a file and a page to split at!");

    return false;
  }

  return split(file, page);
}, true);

luckyButton.addEventListener('click', e => {
  e.preventDefault();

  const file = fileInput.files[0];

  if (!file) {
    alert("You can't get lucky without a file!");

    return false;
  }

  return split(file);
}, true);
