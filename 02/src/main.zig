const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var cube_color_threshold = std.StringHashMap(u8).init(allocator);
    defer cube_color_threshold.deinit();

    try cube_color_threshold.put("red", 12);
    try cube_color_threshold.put("green", 13);
    try cube_color_threshold.put("blue", 14);

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var id_sum: u64 = 0;
    var power_sum: u64 = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitAny(u8, line, ":,;");
        const first = it.first();
        const id = first[std.mem.indexOf(u8, first, " ").? + 1 ..];
        var is_valid_game = true;
        var max_red: u64 = 1;
        var max_green: u64 = 1;
        var max_blue: u64 = 1;
        while (it.peek() != null) {
            const count_color = std.mem.trimLeft(u8, it.next().?, " ");
            var cube_it = std.mem.split(u8, count_color, " ");
            const count = try std.fmt.parseInt(u32, cube_it.next().?, 10);
            const color = cube_it.next().?;

            const Color = enum { red, green, blue };
            const color_enum = std.meta.stringToEnum(Color, color) orelse return;
            switch (color_enum) {
                .red => max_red = @max(max_red, count),
                .green => max_green = @max(max_green, count),
                .blue => max_blue = @max(max_blue, count),
            }
            if (count > cube_color_threshold.get(color).?) {
                is_valid_game = false;
            }
        }

        power_sum += max_red * max_green * max_blue;
        if (is_valid_game) {
            id_sum += try std.fmt.parseInt(u32, id, 10);
        }
    }
    std.log.info("sum of valid ids: {d}", .{id_sum});
    std.log.info("sum of required power: {d}", .{power_sum});
}
