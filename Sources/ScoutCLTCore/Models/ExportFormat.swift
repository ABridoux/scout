//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Scout

/// Models the value the export process can take
public enum ExportFormat: String, CaseIterable, Equatable {
    case json, plist, yaml, xml, array, dictionary
}
