const { Writable } = require('stream');

class WritableMock extends Writable {
  constructor({
    throwInWrite, requireDrain, callWriteCallbackWithAnError,
    fireOnErrorWithoutCallback, callCallback,
  }) {
    super();
    this.throwInWrite = throwInWrite;
    this.requireDrain = requireDrain;
    this.callWriteCallbackWithAnError = callWriteCallbackWithAnError;
    this.fireOnErrorWithoutCallback = fireOnErrorWithoutCallback;
    this.callCallback = callCallback;
  }

  _write(chunk, encoding, callback) {
    if (this.fireOnErrorWithoutCallback) {
      this.emit('error', new Error('Error event'));
      return;
    }
    if (this.callWriteCallbackWithAnError) {
      callback(new Error('Error from callback'));
      return;
    }
    if (this.throwInWrite) {
      throw new Error('Thrown error');
    }
    if (this.callCallback) {
      callback();
    }
  }
}

module.exports = WritableMock;