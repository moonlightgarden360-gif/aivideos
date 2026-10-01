# Iapetus: The Two-Faced Moon (5-minute cut)

5:00 faceless space documentary in the Astrum style, condensed from `../script-iapetus.md`.

- **Footage:** 20 × 15 s Seedance 2.0 clips (fast mode, 720p, 16:9), upscaled to 1920×1080 in the final render
- **Narration:** one AI narrator line per 15 s clip, starting 0.6 s into each clip
- **Music:** a synthesized ambient drone bed kept well under the voice
- **Captions:** none burned in. Astrum doesn't use them; upload auto-captions on YouTube instead.

## Narration (final takes)

| # | Line |
|---|---|
| 1 | In sixteen seventy-one, Giovanni Cassini discovered a new moon of Saturn. Then, it vanished. On one side of Saturn, it shone clearly. On the other, it was gone. |
| 2 | Cassini guessed why. One half of this moon must be bright as snow, and the other almost black. He was right. But it took three centuries to learn just how strange this place really is. |
| 3 | Because the two faces aren't the strangest thing about it. This moon also has a wall: a mountain range over ten kilometres high, running almost perfectly around its equator. And nobody knows why. |
| 4 | This is Iapetus, Saturn's two-faced moon. It's about fourteen hundred and seventy kilometres across, roughly the distance from London to Rome. Today, we're going there to try and solve its mysteries. |
| 5 | Iapetus lives far out, about three and a half million kilometres from Saturn. One orbit takes seventy-nine days, and because it's tidally locked, a single day here lasts seventy-nine days too. |
| 6 | It's barely denser than water, so it's mostly ice. And its orbit is tilted, so from its surface you'd see Saturn's rings opened out across the sky, not edge-on. That would be quite a view. |
| 7 | Its trailing side reflects more than half the sunlight that hits it. But its leading side, the side facing forward in its orbit, reflects only about four percent. That's as dark as fresh asphalt. |
| 8 | Arthur C. Clarke's novel, 2001: A Space Odyssey, imagined that bright patch as artificial, a signpost left for us. The truth turned out to be stranger. |
| 9 | In two thousand and four, the Cassini spacecraft reached Saturn. Up close, Iapetus's dark coat proved thin. Small, young craters had punched right through it, to bright ice below. |
| 10 | So where did the dark coat come from? There's one big clue. The dark side is the leading side. Think of driving through a swarm of insects. Only the windscreen gets splattered. |
| 11 | Far beyond Iapetus, a small, dark moon called Phoebe orbits Saturn backwards. In two thousand and nine, a telescope found a giant ring of dust coming from it. |
| 12 | It's the largest known ring around any planet. Around a billion Earths could fit inside it. That dust spirals inward, and because it's moving backwards, it hits Iapetus head-on. |
| 13 | But dust alone would leave a soft smudge, and Iapetus has sharp, stark edges. Something is amplifying the effect. And the answer, it seems, comes from that incredibly long day. |
| 14 | Dark patches absorb more sunlight, so they warm up slightly. That's enough for the ice there to turn into vapour, drift away, and freeze again on colder, brighter ground. |
| 15 | So dark areas get darker, and bright areas get brighter. It's a runaway loop that may have run for billions of years. Clarke's signpost was painted by dust, and by the Sun. |
| 16 | Now, that wall. The main ridge stretches for around thirteen hundred kilometres. In places, it rises about twenty kilometres high. That's more than twice the height of Mount Everest. |
| 17 | Iapetus is also squashed, shaped like a moon spinning once every sixteen hours. Yet today, it spins once every seventy-nine days. Its shape seems to have frozen in place when it was young. |
| 18 | One idea is that the crust buckled as its spin slowed. Another is more dramatic: that Iapetus once had a ring of its own, which slowly fell, raining debris along its equator. |
| 19 | No one knows which is right. Cassini ended its mission in twenty seventeen, plunging into Saturn, and no spacecraft is planned to return. For now, Iapetus keeps its secrets. |
| 20 | Three and a half centuries ago, one man noticed a point of light that disappeared. What we found there was stranger than fiction. Which moon should we visit next? Let me know below. |

## YouTube upload kit

> Superseded by the full package in [`youtube/UPLOAD-KIT.md`](youtube/UPLOAD-KIT.md) (thumbnails, SRT, settings, end screen). The draft below is kept for reference.

**Title:** Cassini Found Something Very Strange on Saturn's Moon Iapetus

**Alt titles (A/B test):** The Moon With Two Faces and a Wall Around Its Middle · Why Does This Moon Look Fake?

**Description:**
> In 1671, Giovanni Cassini discovered a moon of Saturn, and then watched it vanish. Three centuries later, a spacecraft found out why, and uncovered an even bigger mystery: a mountain ridge twice the height of Everest running around the moon's equator.
>
> 0:00 The moon that vanished
> 0:45 Meet Iapetus
> 1:45 Clarke's signpost
> 2:00 Cassini arrives
> 2:30 The dust from a backwards moon
> 3:00 How the Sun paints a moon
> 3:45 The wall around the middle
> 4:30 What we still don't know
>
> Visuals are AI-generated illustrations, not real spacecraft imagery.
>
> Sources: Porco et al. 2005 (Science); Verbiscer, Skrutskie & Hamilton 2009 (Nature); Spencer & Denk 2010 (Science); Castillo-Rogez et al. 2007 (Icarus); NASA Science, "Iapetus".

**Tags:** iapetus, saturn, saturn moons, cassini, space documentary, solar system, astronomy, phoebe ring, space mystery, planetary science

**Disclosure:** In YouTube Studio, tick "Altered or synthetic content". The visuals are realistic-looking AI renders.

**Thumbnail:** two-toned Iapetus on black with a red circle around the ridge and the text "TWO FACES?"

## Output

- **Final video:** https://d2ol7oe51mr4n9.cloudfront.net/user_3K69pG2g2JSyY9om1coUqUz4cIm/8098d2e0-62ea-49ad-b5b4-f5a5c247515c.mp4
- 1920×1080, 24 fps, H.264 + AAC 192k, exactly 5:00, about 247 MB, loudness −14.6 LUFS (YouTube's target)
- Cost: about 770 Higgsfield credits (20 clips × 37.5, plus narration and 2 reference images)

## Rebuilding

`clip_urls.txt` and `vo_urls.txt` list every source take. Put them in a folder as `clips.txt` and `vo.txt`, then run `assemble.sh` there (needs ffmpeg and curl). To swap a shot, regenerate that clip and replace its line.

Known nit: clip 05 (1:00–1:15) shows Saturn twice in the frame.
