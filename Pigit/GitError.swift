import Foundation

public enum GitError: LocalizedError {
    public enum Repository: LocalizedError {
        case alreadyExists
    }
}
