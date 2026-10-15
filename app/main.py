"""
A deliberately tiny Flask app.

The app is NOT the point of this project. It's the "luggage" that goes
through the security checkpoints. Keeping it small means every gate
failure you see is caused by the thing you're testing, not by app bugs.
"""

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/health")
def health():
    # A health endpoint gives you something to hit later
    # to prove the container actually starts and responds.
    return jsonify(status="ok")


if __name__ == "__main__":
    # 127.0.0.1 (localhost only), NOT 0.0.0.0 (every network interface).
    # Bandit flags 0.0.0.0 as a risk because it exposes the app to the
    # whole network. Inside Docker we'll start it a different way (gunicorn),
    # so this line only matters when you run it on your laptop.
    app.run(host="127.0.0.1", port=5000)
