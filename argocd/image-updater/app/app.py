from flask import Flask

app = Flask(__name__)

@app.route('/')
def version():
    return "This is image version 1.0.3"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
