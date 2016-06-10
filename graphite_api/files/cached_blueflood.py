import blueflood
import memcache
import sys

memcache_client = memcache.Client(['127.0.0.1:11211'], debug=0)

def sanitize_key(unicode_key):
    """
    Memcache expects keys to be strings. Unicode strings will not work.

    @param key - Unicode String

    """
    if isinstance(unicode_key, unicode):
        key = unicode_key.encode('latin1')
    return key


def already_cached(finder):
    """
    Checks to see if the finder class has already been modified.

    @param finder - Class that should contain a find_metrics method.

    """
    return hasattr(finder, '__cached_find_metrics__')


def cache_find_metrics(finder):
    """
    Wraps the find_metrics class method of the class finder with a version
    that stores results in memcache.

    @param finder - Class containing find_metrics method.

    """
    if hasattr(finder, 'find_metrics') and not already_cached(finder):
        original_find_metrics = getattr(finder, 'find_metrics')

        def find_metrics(self, query):
            key = sanitize_key('query:%s' % query)
            try:
                results = memcache_client.get(key)
            except Exception:
                results = []
            if not results:
                results = original_find_metrics(self, query)
                memcache_client.set(key, results, 60 * 60 * 12)
            return results

        # Set new find_metrics method and mark class as modified
        setattr(finder, 'find_metrics', find_metrics)
        setattr(finder, '__cached_find_metrics__', True)
    return finder

TenantBluefloodFinder = cache_find_metrics(blueflood.TenantBluefloodFinder)
