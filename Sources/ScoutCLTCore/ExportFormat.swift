//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout

/// Models the value the export process can take
public enum ExportFormat: String, CaseIterable, ExpressibleByArgument, Equatable {
    case json, plist, yaml, xml, array, dict
}
