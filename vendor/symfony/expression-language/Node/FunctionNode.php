<?php

/*
 * This file is part of the Symfony package.
 *
 * (c) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace _PhpScoper5eddef0da618a\Symfony\Component\ExpressionLanguage\Node;

use _PhpScoper5eddef0da618a\Symfony\Component\ExpressionLanguage\Compiler;
/**
 * @author Fabien Potencier <fabien@symfony.com>
 *
 * @internal
 */
class FunctionNode extends \_PhpScoper5eddef0da618a\Symfony\Component\ExpressionLanguage\Node\Node
{
    public function __construct($name, \_PhpScoper5eddef0da618a\Symfony\Component\ExpressionLanguage\Node\Node $arguments)
    {
        parent::__construct(['arguments' => $arguments], ['name' => $name]);
    }
    public function compile(\_PhpScoper5eddef0da618a\Symfony\Component\ExpressionLanguage\Compiler $compiler)
    {
        $arguments = [];
        foreach ($this->nodes['arguments']->nodes as $node) {
            $arguments[] = $compiler->subcompile($node);
        }
        $function = $compiler->getFunction($this->attributes['name']);
        $compiler->raw(\call_user_func_array($function['compiler'], $arguments));
    }
    public function evaluate($functions, $values)
    {
        $arguments = [$values];
        foreach ($this->nodes['arguments']->nodes as $node) {
            $arguments[] = $node->evaluate($functions, $values);
        }
        return \call_user_func_array($functions[$this->attributes['name']]['evaluator'], $arguments);
    }
    public function toArray()
    {
        $array = [];
        $array[] = $this->attributes['name'];
        foreach ($this->nodes['arguments']->nodes as $node) {
            $array[] = ', ';
            $array[] = $node;
        }
        $array[1] = '(';
        $array[] = ')';
        return $array;
    }
}