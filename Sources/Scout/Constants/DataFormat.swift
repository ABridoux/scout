//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

/// Unique identifier of a data format.
public enum DataFormat: String, CaseIterable {
    case json
    case plist
    case xml
    case yaml
}
