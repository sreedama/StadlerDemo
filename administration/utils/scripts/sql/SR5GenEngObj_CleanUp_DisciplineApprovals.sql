UPDATE PSR5GENENGOBJREVISION
SET psr5WeldReleasedBy = NULL, psr5WeldReleaseDate = NULL, psr5ScrewReleasedBy = NULL, psr5ScrewReleaseDate = NULL, psr5GlueReleasedBy = NULL, psr5GlueReleaseDate = NULL;
COMMIT;

UPDATE PSR5ITEMREVISION
SET psr5ReviewedBy = NULL, psr5DateReviewed = NULL, psr5ReleasedBy = NULL
COMMIT;