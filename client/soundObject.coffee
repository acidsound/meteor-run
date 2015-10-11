@AudioContext = @AudioContext or window.webkitAudioContext
@soundObject =
  context: null
  isInit: false
  mtof: (midi)->
    440.0 * Math.pow(2, (Math.floor(midi) - 69) / 12.0)
  makeDistortionCurve: (amount) ->
    k = if typeof amount == 'number' then amount else 50
    n_samples = 44100
    curve = new Float32Array(n_samples)
    deg = Math.PI / 180
    i = 0
    x = undefined
    while i < n_samples
      x = i * 2 / n_samples - 1
      curve[i] = (3 + k) * x * 20 * deg / (Math.PI + k * Math.abs(x))
      ++i
    curve
  initAudio: ->
    @context = new AudioContext();
    @osc = @context.createOscillator()
    @gain = @context.createGain()
    @gain.gain.value = 0
    @osc.connect @gain
    @gain.connect @context.destination
    @osc.start 0
    @osc.stop @context.currentTime+0.001
    @isInit= true
  beep: (step)->
    @context = @context or new AudioContext();
    c=@context.currentTime
    @osc = @context.createOscillator()
    @osc.type= 'square'
    @osc.frequency.value = @mtof (4*(~~(Math.random()*4)))+61+( !(step%8) and 24 or 0)
    l = ( !(step%16) and 1.2 or (!(step%8) and 0.5 or 0.1))
    @lp = @context.createBiquadFilter()
    @lp.type = "lowshelf"
    @lp.gain.setValueAtTime 0.2, c
    @lp.gain.exponentialRampToValueAtTime 10, c+l
    @lp.frequency.setValueAtTime 100, c
    @lp.frequency.exponentialRampToValueAtTime 1000, c+l
    @gain = @context.createGain()
    @gain.gain.setValueAtTime 0, c
    @gain.gain.setValueAtTime 0.4, c+0.02
    @gain.gain.exponentialRampToValueAtTime 0.01, c+l

    distortion = @context.createWaveShaper()
    distortion.curve = @makeDistortionCurve 400
    distortion.oversample = '4x'
    @osc.connect distortion
    distortion.connect @lp
    @lp.connect @gain
    @gain.connect @context.destination
    @gain.gain.set
    @osc.start 0
    @osc.stop c+l
  die: ->
    @context = @context or new AudioContext();
    c=@context.currentTime
    l=1.3
    @osc = @context.createOscillator()
    @osc.type= 'sawtooth'
    @lp = @context.createBiquadFilter()
    @lp.type = "lowshelf"
    @lp.gain.setValueAtTime 0.8, c
    @lp.gain.exponentialRampToValueAtTime 10, c+l
    @lp.frequency.setValueAtTime 100, c

    @osc.frequency.setValueAtTime 800, c
    @osc.frequency.exponentialRampToValueAtTime 600, c+(l*1/8)
    @osc.frequency.exponentialRampToValueAtTime 700, c+(l*2/8)
    @osc.frequency.exponentialRampToValueAtTime 500, c+(l*3/8)
    @osc.frequency.exponentialRampToValueAtTime 600, c+(l*4/8)
    @osc.frequency.exponentialRampToValueAtTime 400, c+(l*5/8)
    @osc.frequency.exponentialRampToValueAtTime 500, c+(l*6/8)
    @osc.frequency.exponentialRampToValueAtTime 300, c+(l*7/8)
    @osc.frequency.exponentialRampToValueAtTime 50, c+(l*8/8)

    @gain = @context.createGain()
    @gain.gain.setValueAtTime 0, c
    @gain.gain.setValueAtTime 0.4, c+0.02
    @gain.gain.exponentialRampToValueAtTime 0.01, c+l
    @osc.connect @lp
    @lp.connect @gain
    @gain.connect @context.destination
    @gain.gain.set
    @osc.start 0
    @osc.stop c+l
