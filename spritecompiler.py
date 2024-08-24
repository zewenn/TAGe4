from PIL import Image
from dataclasses import dataclass
import os


ascii_brightness_map = [
    " ",  # 0: Darkest
    ".",  # 1
    ",",  # 2
    ":",  # 3
    ";",  # 4
    "-",  # 5
    "~",  # 6
    "=",  # 7
    "+",  # 8
    "*",  # 9
    "#",  # 10
    "%",  # 11
    "&",  # 12
    "@",  # 13
    "B",  # 14
    "M",  # 15: Brightest
]


@dataclass
class Sprite:
    name: str
    sprite_data: list[list[tuple[int, int, int]]]
    size: tuple[int, int]


def load_image_to_2d_array(file_path) -> list[list[tuple[int, int, int]]]:
    img = Image.open(file_path)
    img = img.convert("RGBA")

    width, height = img.size
    pixel_array = []

    for y in range(height):
        row = []
        for x in range(width):
            row.append(img.getpixel((x, y)))
        pixel_array.append(row)

    return pixel_array


def get_pixel_brightness(lightmap: list[str], value: int) -> str:
    level = value / len(lightmap)
    level = min(255, level)
    level = max(0, level)
    level = int(level)

    return lightmap[level]


def generate_zig_code(s: Sprite) -> str:
    res = f"pub const {s.name}: *Sprite({s.size[0] * 2}, {s.size[1]})"
    res += f" = @constCast(&Sprite({s.size[0] * 2}, {s.size[1]})"
    res += f".init([_][{s.size[0] * 2}]Cell" + "{"
    for row in s.sprite_data:
        res += "[_]Cell{"

        for col in row:
            for _ in range(2):
                res += "Cell{"
                res += (
                    f".value = '{get_pixel_brightness(ascii_brightness_map, col[3])}', "
                )
                res += ".foreground = .{"
                res += f".red = {col[0]}, .green = {col[1]}, .blue = {col[2]}"
                res += "},"
                res += "},"

        res += "},"

    res += "}));"

    return res


def main() -> None:
    cwd = os.getcwd()
    sprite_path = os.path.join(cwd, "src", "assets")
    temp_path = os.path.join(cwd, "src", ".temp")

    sprites_paths = [os.path.join(sprite_path, x) for x in os.listdir(sprite_path)]
    sprites: list[Sprite] = []

    for pth in sprites_paths:
        data = load_image_to_2d_array(pth)
        sprites.append(
            Sprite(
                os.path.basename(pth).split(".")[0],
                data,
                (data[0].__len__(), data.__len__()),
            )
        )

    outfile = ""
    outfile += 'const Sprite = @import("../sys/screen.zig").Sprite;\n'
    outfile += 'const Cell = @import("../sys/screen.zig").Cell;\n'

    for sprite in sprites:
        outfile += generate_zig_code(sprite)

    with open(os.path.join(temp_path, "assets.zig"), "w", encoding="utf8") as wf:
        wf.write(outfile)


if __name__ == "__main__":
    main()
