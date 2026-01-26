from flask import Flask, request, jsonify
import speech_recognition as sr
import os

app = Flask(__name__)

# Ensure temp directory exists
TEMP_DIR = "temp_audio"
if not os.path.exists(TEMP_DIR):
    os.makedirs(TEMP_DIR)

@app.route('/recognize', methods=['POST'])
def recognize_speech():
    if 'audio' not in request.files:
        return jsonify({"success": False, "error": "No audio file provided"}), 400
    
    filename = None
    try:
        audio_file = request.files['audio']
        # Save explicitly as .wav
        # Use absolute path to be safe
        filename = os.path.join(TEMP_DIR, f"temp_recording_{os.urandom(4).hex()}.wav")
        audio_file.save(filename)
        
        # Initialize recognizer
        r = sr.Recognizer()
        
        # Load audio data using the library's helper method (found in repo's audio.py)
        # This is cleaner than manual context management if we just want the whole file
        # Note: 'SpeechRecognition' package installed via pip matches this logic
        try:
            # AudioData.from_file is a classmethod available in newer versions/repo
            # If not available in installed pip version, we prioritize the standard way
            # But since user specifically pointed to repo, let's try to use the repo-style logic
            # However, to be safe against version mismatches, we'll use the standard approach
            # if from_file isn't usually exposed or if it's just a wrapper.
            # Actually, let's use the explicit context manager as it's the most robust way in examples/audio_transcribe.py
            
            with sr.AudioFile(filename) as source:
                audio_data = r.record(source)
                
            # Recognize speech using Google Speech Recognition
            # using 'en-IN' as per requirements
            text = r.recognize_google(audio_data, language="en-IN")
            
            # Logic from requirements: "Extract first valid name token" & "Capitalize"
            clean_text = text.lower().replace("my name is", "").replace("i am", "").strip()
            formatted_name = clean_text.title()
            
            response = jsonify({
                "success": True, 
                "text": formatted_name,
                "original_text": text
            })
            
        except AttributeError:
             # Fallback if needed, but AudioFile is standard
             return jsonify({"success": False, "error": "Audio processing error"}), 500
             
    except sr.UnknownValueError:
        response = jsonify({"success": False, "error": "Speech not detected. Please speak clearly."})
    except sr.RequestError as e:
        response = jsonify({"success": False, "error": f"Service unavailable: {e}"})
        response.status_code = 503
    except Exception as e:
        response = jsonify({"success": False, "error": f"Server error: {str(e)}"})
        response.status_code = 500
    finally:
        # CLEANUP: Delete the temp file
        if filename and os.path.exists(filename):
            try:
                os.remove(filename)
            except:
                pass

    return response

if __name__ == '__main__':
    # Run on 0.0.0.0 to accessible from emulator/device
    app.run(host='0.0.0.0', port=5000, debug=True)
