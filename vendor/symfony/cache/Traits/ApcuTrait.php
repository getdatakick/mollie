<?php

/*
 * This file is part of the Symfony package.
 *
 * (c) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace _PhpScoper5eddef0da618a\Symfony\Component\Cache\Traits;

use _PhpScoper5eddef0da618a\Symfony\Component\Cache\CacheItem;
use _PhpScoper5eddef0da618a\Symfony\Component\Cache\Exception\CacheException;
/**
 * @author Nicolas Grekas <p@tchwork.com>
 *
 * @internal
 */
trait ApcuTrait
{
    public static function isSupported()
    {
        return \function_exists('_PhpScoper5eddef0da618a\\apcu_fetch') && \filter_var(\ini_get('apc.enabled'), \FILTER_VALIDATE_BOOLEAN);
    }
    private function init($namespace, $defaultLifetime, $version)
    {
        if (!static::isSupported()) {
            throw new \_PhpScoper5eddef0da618a\Symfony\Component\Cache\Exception\CacheException('APCu is not enabled.');
        }
        if ('cli' === \PHP_SAPI) {
            \ini_set('apc.use_request_time', 0);
        }
        parent::__construct($namespace, $defaultLifetime);
        if (null !== $version) {
            \_PhpScoper5eddef0da618a\Symfony\Component\Cache\CacheItem::validateKey($version);
            if (!apcu_exists($version . '@' . $namespace)) {
                $this->doClear($namespace);
                apcu_add($version . '@' . $namespace, null);
            }
        }
    }
    /**
     * {@inheritdoc}
     */
    protected function doFetch(array $ids)
    {
        try {
            foreach (apcu_fetch($ids, $ok) ?: [] as $k => $v) {
                if (null !== $v || $ok) {
                    (yield $k => $v);
                }
            }
        } catch (\Error $e) {
            throw new \ErrorException($e->getMessage(), $e->getCode(), \E_ERROR, $e->getFile(), $e->getLine());
        }
    }
    /**
     * {@inheritdoc}
     */
    protected function doHave($id)
    {
        return apcu_exists($id);
    }
    /**
     * {@inheritdoc}
     */
    protected function doClear($namespace)
    {
        return isset($namespace[0]) && \class_exists('_PhpScoper5eddef0da618a\\APCuIterator', \false) && ('cli' !== \PHP_SAPI || \filter_var(\ini_get('apc.enable_cli'), \FILTER_VALIDATE_BOOLEAN)) ? apcu_delete(new \_PhpScoper5eddef0da618a\APCuIterator(\sprintf('/^%s/', \preg_quote($namespace, '/')), APC_ITER_KEY)) : apcu_clear_cache();
    }
    /**
     * {@inheritdoc}
     */
    protected function doDelete(array $ids)
    {
        foreach ($ids as $id) {
            apcu_delete($id);
        }
        return \true;
    }
    /**
     * {@inheritdoc}
     */
    protected function doSave(array $values, $lifetime)
    {
        try {
            if (\false === ($failures = apcu_store($values, null, $lifetime))) {
                $failures = $values;
            }
            return \array_keys($failures);
        } catch (\Error $e) {
        } catch (\Exception $e) {
        }
        if (1 === \count($values)) {
            // Workaround https://github.com/krakjoe/apcu/issues/170
            apcu_delete(\key($values));
        }
        throw $e;
    }
}
