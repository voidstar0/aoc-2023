const std = @import("std");

const SearchResult = struct {
    index: ?usize,
    digit: []const u8,
};

fn searchFirst(str: []const u8, list: []const []const u8) SearchResult {
    var smallest_index: ?usize = null;
    var digit: []const u8 = undefined;
    for (list) |s| {
        const index = std.mem.indexOf(u8, str, s);
        if (smallest_index == null and index != null) {
            smallest_index = index.?;
            digit = s;
        } else if (index != null and index.? < smallest_index.?) {
            smallest_index = index.?;
            digit = s;
        }
    }
    return SearchResult{ .index = smallest_index, .digit = digit };
}

fn searchLast(str: []const u8, list: []const []const u8) SearchResult {
    var largest_index: ?usize = null;
    var digit: []const u8 = undefined;
    for (list) |s| {
        const index = std.mem.indexOf(u8, str, s);
        if (largest_index == null and index != null) {
            largest_index = index.?;
            digit = s;
        } else if (index != null and index.? > largest_index.?) {
            largest_index = index.?;
            digit = s;
        }
    }
    return SearchResult{ .index = largest_index, .digit = digit };
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var sum: u64 = 0;

    const digit_list = &.{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    const allocator = std.heap.page_allocator;
    var digit_map = std.StringHashMap(u8).init(allocator);
    defer digit_map.deinit();

    // Map to convert from word -> number
    try digit_map.put("zero", 0);
    try digit_map.put("one", 1);
    try digit_map.put("two", 2);
    try digit_map.put("three", 3);
    try digit_map.put("four", 4);
    try digit_map.put("five", 5);
    try digit_map.put("six", 6);
    try digit_map.put("seven", 7);
    try digit_map.put("eight", 8);
    try digit_map.put("nine", 9);

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // Find the first and last digits written as numbers in the line
        const first = std.mem.indexOflist(u8, line, "0123456789") orelse null;
        const last = std.mem.lastIndexOflist(u8, line, "0123456789") orelse null;

        // Find the first and last digits written as strings in the line
        const first_replacement = searchFirst(line, digit_list);
        const last_replacement = searchLast(line, digit_list);

        var actual_first: u8 = 0;
        var actual_last: u8 = 0;

        if (first != null) {
            var buf_1: [1]u8 = undefined;
            _ = try std.fmt.bufPrint(&buf_1, "{c}", .{line[first.?]});
            actual_first = try std.fmt.parseInt(u8, &buf_1, 10);
        }

        if (last != null) {
            var buf_2: [1]u8 = undefined;
            _ = try std.fmt.bufPrint(&buf_2, "{c}", .{line[last.?]});
            actual_last = try std.fmt.parseInt(u8, &buf_2, 10);
        }

        // Compare if the string or number came first and use that for the first digit
        if (first == null or first_replacement.index.? < first.?) {
            actual_first = digit_map.get(first_replacement.digit).?;
        }

        // Compare if the string or number came last and use that for the next digit
        if (last == null or last_replacement.index.? > last.?) {
            actual_last = digit_map.get(last_replacement.digit).?;
        }

        // Combine the digits into a number and add it to the sum
        var digits: [2]u8 = undefined;
        _ = try std.fmt.bufPrint(&digits, "{d}{d}", .{ actual_first, actual_last });
        sum += try std.fmt.parseInt(u64, &digits, 10);
    }
    std.log.info("sum: {d}", .{sum});
}
