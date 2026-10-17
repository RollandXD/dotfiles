"""常驻的 CPU Kokoro 进程；stdin/stdout 为 JSON，不输出待朗读文本。"""
import json
import os
from pathlib import Path
import sys

os.environ.setdefault('OMP_NUM_THREADS', '2')
os.environ.setdefault('TOKENIZERS_PARALLELISM', 'false')


def main():
    import numpy as np
    import onnxruntime as ort
    import soundfile as sf
    from kokoro_onnx import Kokoro
    from misaki import en, espeak
    import spacy
    if not spacy.util.is_package('en_core_web_sm'):
        raise RuntimeError('English model missing')
    models = Path(os.environ.get('XDG_DATA_HOME') or Path.home() / '.local/share') / 'english-lookup/models/kokoro'
    options = ort.SessionOptions()
    options.intra_op_num_threads = 2
    options.inter_op_num_threads = 1
    session = ort.InferenceSession(str(models / 'kokoro-v1.0.int8.onnx'),
                                   sess_options=options, providers=['CPUExecutionProvider'])
    kokoro = Kokoro.from_session(session, str(models / 'voices-v1.0.bin'))
    g2p = en.G2P(trf=False, british=False, fallback=espeak.EspeakFallback(british=False))
    for line in sys.stdin:
        try:
            request = json.loads(line)
            phonemes, _ = g2p(request['text'])
            if not phonemes.strip():
                raise ValueError('empty phonemes')
            audio, rate = kokoro.create(phonemes, voice=request.get('voice', 'af_heart'),
                                        speed=0.95, lang='en-us', is_phonemes=True)
            if not np.isfinite(audio).all() or len(audio) < rate * 0.1:
                raise ValueError('invalid audio')
            # 响度统一与首尾留白由主进程 level_audio 处理，与词典录音一致。
            sf.write(request['path'], audio, rate, subtype='PCM_16')
            reply = {'ok': True, 'rate': rate, 'seconds': len(audio) / rate}
        except Exception as error:
            reply = {'ok': False, 'error': type(error).__name__}
        print(json.dumps(reply), flush=True)


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(json.dumps({'ok': False, 'error': type(error).__name__}), flush=True)
