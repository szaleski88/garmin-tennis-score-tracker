const fs = require("fs");
const zlib = require("zlib");

function crc32(buf) {
  if (!crc32.table) {
    crc32.table = new Uint32Array(256);
    for (let i = 0; i < 256; i++) {
      let c = i;
      for (let k = 0; k < 8; k++) {
        c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
      }
      crc32.table[i] = c >>> 0;
    }
  }

  let c = 0xffffffff;
  for (const b of buf) {
    c = crc32.table[(c ^ b) & 0xff] ^ (c >>> 8);
  }
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const typeBuf = Buffer.from(type, "ascii");
  const len = Buffer.alloc(4);
  const crcBuf = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}

function png(width, height, rgbaFn) {
  const raw = Buffer.alloc((width * 4 + 1) * height);
  let offset = 0;

  for (let y = 0; y < height; y++) {
    raw[offset++] = 0;
    for (let x = 0; x < width; x++) {
      const p = rgbaFn(x, y);
      raw[offset++] = p[0];
      raw[offset++] = p[1];
      raw[offset++] = p[2];
      raw[offset++] = p[3];
    }
  }

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;

  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk("IHDR", ihdr),
    chunk("IDAT", zlib.deflateSync(raw)),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

function ballPixel(size, cx, cy, radius, x, y) {
  const dx = x + 0.5 - cx;
  const dy = y + 0.5 - cy;
  const d = Math.sqrt(dx * dx + dy * dy);

  if (d > radius) {
    return [0, 0, 0, 0];
  }

  let r = 190;
  let g = 235;
  let b = 44;

  if (Math.abs(d - radius) < 1.5) {
    r = 245;
    g = 255;
    b = 92;
  }

  const curvedSeam = Math.abs(dx + 0.42 * dy) < 1.15 && Math.abs(d - radius * 0.62) < radius * 0.45;
  const centerSeam = Math.abs(dx + 0.42 * dy) < 1.15 && Math.abs(d + radius * 0.06) < radius * 0.72;

  if (curvedSeam || centerSeam) {
    r = 255;
    g = 255;
    b = 255;
  }

  if (x < size * 0.38 && y < size * 0.35) {
    r = Math.min(255, r + 24);
    g = Math.min(255, g + 18);
  }

  return [r, g, b, 255];
}

function main() {
  fs.mkdirSync("resources/images", { recursive: true });

  const ball = png(22, 22, (x, y) => ballPixel(22, 11, 11, 9.8, x, y));
  const icon = png(70, 70, (x, y) => {
    const dx = x + 0.5 - 35;
    const dy = y + 0.5 - 35;
    const d = Math.sqrt(dx * dx + dy * dy);

    if (d > 34) {
      return [0, 0, 0, 0];
    }

    if (d > 30) {
      return [255, 255, 255, 255];
    }

    const p = ballPixel(70, 35, 35, 26, x, y);
    if (p[3] > 0) {
      return p;
    }

    return [0, 0, 0, 255];
  });

  fs.writeFileSync("resources/images/tennis_ball.png", ball);
  fs.writeFileSync("resources/images/launcher_icon.png", icon);
}

main();
